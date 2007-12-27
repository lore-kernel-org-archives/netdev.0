From: Andreas Mohr <andi@lisas.de>
Subject: Re: [PATCH 2.6.24-rc3] Fix /proc/net breakage
Date: Thu, 27 Dec 2007 23:17:28 +0100
Message-ID: <20071227221728.GA17379@rhlx01.hs-esslingen.de>
References: <20071119191000.GA1560@elf.ucw.cz> <200711192304.25087.rjw@sisk.pl> <4743026B.2020907@openvz.org> <m1hcj8mz1p.fsf_-_@ebiederm.dsl.xmission.com> <1197003097.13978.557.camel@pmac.infradead.org> <20071207022342.806ee4ee.akpm@linux-foundation.org> <20071227174056.GA17350@rhlx01.hs-esslingen.de> <20071227184145.GA1831@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Mohr <andi@lisas.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Woodhouse <dwmw2@infradead.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>,
	kernel list <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Pavel Emelyanov <xemul@openvz.org>,
	"Denis V. Lunev" <den@openvz.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:58648 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752506AbXL0WRa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Dec 2007 17:17:30 -0500
Content-Disposition: inline
In-Reply-To: <20071227184145.GA1831@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, Dec 27, 2007 at 09:41:45PM +0300, Alexey Dobriyan wrote:
> On Thu, Dec 27, 2007 at 06:40:56PM +0100, Andreas Mohr wrote:
> > On Fri, Dec 07, 2007 at 02:23:42AM -0800, Andrew Morton wrote:
> > > > (commit 2b1e300a9dfc3196ccddf6f1d74b91b7af55e416)
> > > > 
> > > > This seems to have broken the use of /proc/bus/usb as a mountpoint. It
> > > > always appears empty now, whatever's supposed to be mounted there.
> > > > 
> > > 
> > > Yes.  Denis and Eric are tossing around competing patches but afaik nobody
> > > is happy with any of them.  Guys, could we get this sorted soonish please?
> > 
> > "Soonish" being rather earlier than 20071227?
> > 'cause it's still throwing a fit for me on 2.6.24-rc6-mm1(!) (plus hotfix),
> > nothing visible in /proc/bus/usb, thus WLAN driver won't probe
> > anything.
> 
> Patch which restores usual behaviour was merged in 2.6.24-rc5
> (3790ee4bd86396558eedd86faac1052cb782e4e1 "proc: remove/Fix proc generic d_revalidate")

Via a kerneltrap.org article (problematic internet setup here currently,
non-C&P text terminal only) I could see that this is the patch which
removes the d_revalidate member and the corresponding proc_revalidate_dentry().
And this is the state that my 2.6.24-rc_six_-mm1 tree is in already.
So either it didn't help here or it broke again by some later change or
there's some dumb PEBKAC error here.

> so no hotfixes are needed. I just checked with bind mounting / to
> /proc/bus/usb -- it works.

OK, I'll try to re-check manual, raw, bare-metal mounting (bind etc.) soonish.

"CONFIG_NETNS" as mentioned in the patch description actually seems
to be "CONFIG_NET_NS", BTW.
(which I DON'T have set at the moment, if this happens to make a difference)

Thanks,

Andreas Mohr
