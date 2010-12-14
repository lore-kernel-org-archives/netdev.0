From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: After memory pressure: can't read from tape anymore
Date: Tue, 14 Dec 2010 14:23:20 -0800
Message-ID: <20101214142320.27d911d5@nehalam>
References: <1290971729.2814.13.camel@larosa>
	<alpine.LNX.2.00.1011291857420.7923@kai.makisara.local>
	<20101203212453W.fujita.tomonori@lab.ntt.co.jp>
	<4CF905D1.6050903@kolumbus.fi>
	<1291388776.2881.4.camel@mulgrave.site>
	<1291395815.2814.376.camel@larosa>
	<1291399814.2881.66.camel@mulgrave.site>
	<4D07D519.70800@vlnb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: James Bottomley <James.Bottomley@suse.de>,
	Lukas Kolbe <lkolbe@techfak.uni-bielefeld.de>,
	Kai =?ISO-8859-1?B?TeRraXNhcmE=?= <kai.makisara@kolumbus.fi>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	linux-scsi@vger.kernel.org, Kashyap Desai <Kashyap.Desai@lsi.com>,
	netdev@vger.kernel.org
To: Vladislav Bolkhovitin <vst@vlnb.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34782 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758105Ab0LNWXZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Dec 2010 17:23:25 -0500
In-Reply-To: <4D07D519.70800@vlnb.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 14 Dec 2010 23:35:37 +0300
Vladislav Bolkhovitin <vst@vlnb.net> wrote:

> What is interesting to me in this regard is how networking with 9K jumbo
> frames manages to work acceptably reliable? Jumbo frames used
> sufficiently often, including under high memory pressure.
> 
> I'm not a deep networking guru, but network drivers need to allocate
> physically continual memory for skbs, which means 16K per 9K packet,
> which means order 2 allocations per skb.

Good network drivers support fragmentation and allocate a small portion
for the header and allocate pages for the rest. This requires no higher
order allocation.  The networking stack takes fragmented data coming
in and does the necessary copy/merging to access contiguous headers.

There are still some crap network drivers that require large contiguous
allocation. These should not be used with jumbo frames in real
environments.

-- 
