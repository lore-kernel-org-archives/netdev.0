From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] gianfar: make local stats atomic64
Date: Wed, 13 Feb 2013 13:18:54 -0500 (EST)
Message-ID: <20130213.131854.1897343233438268526.davem@davemloft.net>
References: <1360715064-2689-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, claudiu.manoil@freescale.com,
	eric.dumazet@gmail.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42708 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760023Ab3BMSS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2013 13:18:56 -0500
In-Reply-To: <1360715064-2689-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Tue, 12 Feb 2013 19:24:22 -0500

> Eric noticed that the handling of local u64 ethtool counters for
> this driver commonly found on Freescale ppc-32 boards was racy.
> 
> However, before converting them over to atomic64_t, I noticed
> that an internal struct was being used to determine the offsets
> for exporting this data into the ethtool buffer, and in doing
> so, it assumed that the counters would always be u64.  Rather
> than keep this implicit assumption, a simple code cleanup gets
> rid of the struct completely, and leaves less conversion sites.
> 
> The alternative solution would have been to take advantage of
> the fact that the counters are all relating to error conditions,
> and hence make them internally u32.  In doing so, we'd be assuming
> that U32_MAX of any particular error condition is highly unlikely.
> This might have made sense if any increments were in a hot path.
> 
> Tested with "ethtool -S eth0" on sbc8548 board.
 ...
>   git://git.kernel.org/pub/scm/linux/kernel/git/paulg/linux.git gfar-ethtool-atomic

Pulled, thanks Paul.
