From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 2.6.24-rc3] Fix /proc/net breakage
Date: Fri, 28 Dec 2007 09:22:01 +0300
Message-ID: <20071228062201.GA2071@martell.zuzino.mipt.ru>
References: <20071119191000.GA1560@elf.ucw.cz> <200711192304.25087.rjw@sisk.pl> <4743026B.2020907@openvz.org> <m1hcj8mz1p.fsf_-_@ebiederm.dsl.xmission.com> <1197003097.13978.557.camel@pmac.infradead.org> <20071207022342.806ee4ee.akpm@linux-foundation.org> <20071227174056.GA17350@rhlx01.hs-esslingen.de> <20071227184145.GA1831@martell.zuzino.mipt.ru> <20071227221728.GA17379@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Woodhouse <dwmw2@infradead.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>,
	kernel list <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Pavel Emelyanov <xemul@openvz.org>,
	"Denis V. Lunev" <den@openvz.org>
To: Andreas Mohr <andi@lisas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:34194 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122AbXL1GWN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Dec 2007 01:22:13 -0500
Received: by ug-out-1314.google.com with SMTP id z38so1764747ugc.16
        for <netdev@vger.kernel.org>; Thu, 27 Dec 2007 22:22:12 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20071227221728.GA17379@rhlx01.hs-esslingen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 27, 2007 at 11:17:28PM +0100, Andreas Mohr wrote:
> Hi,
> 
> On Thu, Dec 27, 2007 at 09:41:45PM +0300, Alexey Dobriyan wrote:
> > On Thu, Dec 27, 2007 at 06:40:56PM +0100, Andreas Mohr wrote:
> > > On Fri, Dec 07, 2007 at 02:23:42AM -0800, Andrew Morton wrote:
> > > > > (commit 2b1e300a9dfc3196ccddf6f1d74b91b7af55e416)
> > > > > 
> > > > > This seems to have broken the use of /proc/bus/usb as a mountpoint. It
> > > > > always appears empty now, whatever's supposed to be mounted there.
> > > > > 
> > > > 
> > > > Yes.  Denis and Eric are tossing around competing patches but afaik nobody
> > > > is happy with any of them.  Guys, could we get this sorted soonish please?
> > > 
> > > "Soonish" being rather earlier than 20071227?
> > > 'cause it's still throwing a fit for me on 2.6.24-rc6-mm1(!) (plus hotfix),
> > > nothing visible in /proc/bus/usb, thus WLAN driver won't probe
> > > anything.
> > 
> > Patch which restores usual behaviour was merged in 2.6.24-rc5
> > (3790ee4bd86396558eedd86faac1052cb782e4e1 "proc: remove/Fix proc generic d_revalidate")
> 
> Via a kerneltrap.org article (problematic internet setup here currently,
> non-C&P text terminal only) I could see that this is the patch which
> removes the d_revalidate member and the corresponding proc_revalidate_dentry().
> And this is the state that my 2.6.24-rc_six_-mm1 tree is in already.

OK.

> So either it didn't help here or it broke again by some later change or
> there's some dumb PEBKAC error here.

Do you by chance forgot CONFIG_USB_?HCI_HCD=y ? I see empty usbfs here if
they are deselected.

> > so no hotfixes are needed. I just checked with bind mounting / to
> > /proc/bus/usb -- it works.
> 
> OK, I'll try to re-check manual, raw, bare-metal mounting (bind etc.) soonish.
> 
> "CONFIG_NETNS" as mentioned in the patch description actually seems
> to be "CONFIG_NET_NS", BTW.
> (which I DON'T have set at the moment, if this happens to make a difference)

I shouldn't.
