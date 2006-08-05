From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH dscape] d80211: Switch d80211.h to IEEE80211_ style names
Date: Sat, 5 Aug 2006 12:46:50 +0100
Message-ID: <20060805114650.GC21135@infradead.org>
References: <200607270037.22384.flamingice@sourmilk.net> <20060731203113.GG10138@tuxdriver.com> <200607311351.35757.flamingice@sourmilk.net> <20060801095650.GA6831@infradead.org> <20060801122142.GB29208@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Michael Wu <flamingice@sourmilk.net>,
	Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:2494 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1161253AbWHELrB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 07:47:01 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
In-Reply-To: <20060801122142.GB29208@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 01, 2006 at 08:21:49AM -0400, John W. Linville wrote:
> I don't anticipate the d80211 naming conventions to ever make it out
> of wireless-dev.  By the time we are ready to push that stuff upstream,
> we will have cleaned-up our messes.

Yes, absolutely.

> This does raise the question: Should we start taking patches to
> wireless-dev that migrate the current (i.e. ieee80211/softmac) stack
> out of the kernel?  This would include (re-)moving the current stack
> code, pointing non-migrated drivers (ipw2[12]00, zd1211rw) at the old
> code, moving drivers out of drivers/net/wireless/d80211 up a level,
> removing the softmac-based version of the bcm43xx driver, etc.

I think you first need to come up with a way to deal with ipw2[12]00,
dealing with that kind of devices is priority number one before the
devicescape stack can go anywhere.  Once that is handled all software
MAC drivers in wireless-dev should be migrated to the device-scape based
stack.

After that we're in the right position to deal with last big step of
the merge:

 a) deal with the userspace interface issue.  Either rever to the single
    network device and eth%d name interface (at least for the non-AP case)
    so existing userspace won't know about the name underlying stack at
    all or alternatively go through the painfull design process for a new
    userspace interface.  I think the first variant will be a lot easier..
 b) do all the small compare and review work.  See how different the interface
    for software mac devices are for softmac vs dscape.  See if any of the
    old code should be reintegrated into dcape, port forward dscape API
    changes to mainline to make merging more gradually.  In the best case
    we'd migrate the current mainline code fully to the finally dscape
    revisited API so the new code really is a drop in, but I don't expect
    that happen, the concepts are just too different.  At least we should
    try to make the interface diff as small a possible.

Once we're there I'm happy to help out on that step b) as much as I can.

