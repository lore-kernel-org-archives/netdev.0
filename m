From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Re: [PATCH v2 15/16] wl1251: Add sysfs file address for setting
 permanent mac address
Date: Wed, 11 Dec 2013 16:53:36 -0600
Message-ID: <1386802416.17188.69.camel@dcbw.foobar.com>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
	 <201312101814.35112@pali> <1386697762.30202.6.camel@dcbw.foobar.com>
	 <201312101852.17030@pali>
	 <1386796654.1516.268.camel@bwh-desktop.uk.level5networks.com>
	 <52A8DA9A.50501@gmail.com>
	 <1386800135.1516.296.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ivajlo Dimitrov <ivo.g.dimitrov.75-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Pali =?ISO-8859-1?Q?Roh=E1r?= <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kalle Valo <kvalo-BkwN83ws05HQT0dZR+AlfA@public.gmane.org>, Luciano Coelho <luca-XPOmlcxoEMv1KXRcyAk9cg@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, freemangordon-uiMcrn6V0Vs@public.gmane.org,
	aaro.koskinen-X3B1VOXEql0@public.gmane.org, pavel-+ZI9xUNit7I@public.gmane.org, sre-GFxCN5SEZAc@public.gmane.org,
	joni.lapilainen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Felipe Contreras <felipe.contreras-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1386800135.1516.296.camel-/LGg1Z1CJKQ+9kgCwbf1HqK4ta4zdZpAajtMo4Cw6ucAvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-12-11 at 22:15 +0000, Ben Hutchings wrote:
> On Wed, 2013-12-11 at 23:35 +0200, Ivajlo Dimitrov wrote:
> > On 11.12.2013 23:17, Ben Hutchings wrote:
> > > I think that's an even worse idea.  This is not firmware and it already
> > > exists in separate storage.
> > >
> > > I think that rx51_init_wl1251() in
> > > arch/arm/mach-omap2/board-rx51-peripherals.c should either copy the MAC
> > > address out of NVRAM, or if it's too early to do that, then schedule a
> > > function to run later and only then set up wl1251 platform data.
> > >
> > > Ben.
> > >
> > 
> > And how will that work with DT when board files will be in the history?
> 
> 1. Boot loader reads the MAC address from NVRAM and puts it in the DT
> node.
> or
> 2. NVRAM reading is done by a tiny driver that is loaded based on the
> platform name and updates the DT node in memory.  (But I don't know how
> wl1251 should decide to defer probing if it's probed before that other
> driver.)

I'm uncomfortable with it too, and yes the permanent MAC should really
be known before the interface is even registered, but...

Imagine if the MAC address for your ethernet device was stored
in /etc/my-mac-addr.txt, except that /etc was a read-only protected
partition from a very small SSD.  That's essentially the N900; it's
stored in a file in a normal ext2/ext3 (?) filesystem on a partition of
the internal flash.  It seems like overkill to write a small driver that
duplicates the ext3 + MTD drivers just to read the MAC.

There's got to be a better way to do this than having it set from
userspace though, but I don't know what that is.  The request_firmware()
method would probably run into race conditions, since who knows if the
partition gets mounted before the WiFi gets initialized?  I suppose the
firmware helper could block until it did, and while that's ugly, it's
the best approach I've seen yet that doesn't violate the "permanent"
idea here.

Dan

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
