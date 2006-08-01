From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH dscape] d80211: Switch d80211.h to IEEE80211_ style
 names
Date: Tue, 1 Aug 2006 15:58:37 +0200
Message-ID: <20060801155837.4c3210aa@griffin.suse.cz>
References: <200607270037.22384.flamingice@sourmilk.net>
	<20060731203113.GG10138@tuxdriver.com>
	<200607311351.35757.flamingice@sourmilk.net>
	<20060801095650.GA6831@infradead.org>
	<20060801122142.GB29208@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>,
	Michael Wu <flamingice@sourmilk.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:7815 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751622AbWHAN6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 09:58:40 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060801122142.GB29208@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Tue, Aug 01, 2006 at 10:56:50AM +0100, Christoph Hellwig wrote:
> > NACK again.  Driver should continue to use the ieee80211.h header forever.

When a patch that renames constants in d80211 is merged and d80211 stack
is moved to ieee80211/ directory, there will be only slight changes (if
any) needed for most drivers. So yes, fullmac drivers will continue to
use ieee80211.h, constants and structures they use will be still the
same, but the header itself will be completely different.

One notable exception is ipw2100 and ipw2200 drivers, but that's another
story.

On Tue, 1 Aug 2006 08:21:49 -0400, John W. Linville wrote:
> This does raise the question: Should we start taking patches to
> wireless-dev that migrate the current (i.e. ieee80211/softmac) stack
> out of the kernel?

I think we should, at least some of them.

> This would include (re-)moving the current stack
> code,

This can be done easily just before merging, no reason for one more
breakage of everyone's drivers now. Furthermore, if we do this now, it
will be more difficult to track Linus' tree.

> pointing non-migrated drivers (ipw2[12]00, zd1211rw) at the old
> code,

Yes. Rather than moving, zd1211 should be ported to d80211 - this will
also allow using of more advanced features of the hw.

> moving drivers out of drivers/net/wireless/d80211 up a level,

I think they should be moved along with the stack - i.e. just before
merging.

> removing the softmac-based version of the bcm43xx driver, etc.

Ditto.

> Whether Michael's patches come before or after this clean-up
> really doesn't matter.  I'd probably rather have them now.  It only
> complicates the migration slightly, while accomplishing something
> useful.

Do you have a plan when you will merge rt2x00 patches so I can apply
Michael's renaming patch(es) without risk of conflicts?

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
