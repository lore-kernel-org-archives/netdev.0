From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] brcmfmac: cfg80211: use msecs_to_jiffies for time
 conversion
Date: Wed, 18 Mar 2015 00:30:56 -0700
Message-ID: <1426663856.10043.15.camel@perches.com>
References: <1426593972-17652-1-git-send-email-hofrat@osadl.org>
	 <1426596159.23897.61.camel@perches.com>
	 <20150318064439.GA25924@opentech.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Nicholas Mc Guire <hofrat-Q945KHDl0DbYtjvyW6yDsg@public.gmane.org>,
	Brett Rudley <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"Franky (Zhenhui) Lin" <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Hante Meuleman <meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Pieter-Paul Giesberts <pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Daniel Kim <dekim-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Nicholas Mc Guire <der.herr-kA1LtwSENNE@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150318064439.GA25924-AxMHDufBahDk7+2FdBfRIA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-03-18 at 07:44 +0100, Nicholas Mc Guire wrote:
> On Tue, 17 Mar 2015, Joe Perches wrote:
> > On Tue, 2015-03-17 at 08:06 -0400, Nicholas Mc Guire wrote:
> > > Converting milliseconds to jiffies by "val * HZ / 1000" is technically
> > > OK but msecs_to_jiffies(val) is the cleaner solution and handles all
> > > corner cases correctly. This is a minor API consolidation only and
> > > should make things more readable.

> > These API consolidation changes now always have a function
> > call when the compiler may have previously been able to
> > optimize out the "constant * HZ / 1000" calculation.
> >
> > Perhaps the [um]secs_to_jiffies calls should be indirected
> > with yet another static inline with a __builtin_constant_p()
> > test so that the function calls can again be avoided when
> > possible.
> 
> will give it a try 

OK, thanks.

The tricky bit seems to be the movement of
the Makefile for kernel/time/timeconst.h.

  BC      kernel/time/timeconst.h

as include/linux/time.h would need these
calculated #defines

#define MSEC_TO_HZ_MUL32	U64_C(0x80000000)
#define MSEC_TO_HZ_ADJ32	U64_C(0x0)
#define MSEC_TO_HZ_SHR32	31

and the usec ones too.

That created file would have to be moved from
kernel/time/Makefile to some other location
that could be in the normal include path like
include/linux/timeconst.h so that it can be
used by include/linux/time.h



--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
