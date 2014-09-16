From: David Miller <davem@davemloft.net>
Subject: Re: bisected regression: 3c59x corrupts packets in 3.17-rc5
Date: Tue, 16 Sep 2014 16:29:23 -0400 (EDT)
Message-ID: <20140916.162923.605101746131407931.davem@davemloft.net>
References: <alpine.LRH.2.11.1409160209280.21050@adalberg.ut.ee>
	<20140916101704.GA3792@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mroos@linux.ee, klassert@mathematik.tu-chemnitz.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140916101704.GA3792@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 16 Sep 2014 06:17:04 -0400

> I'm guessing the above change has uncovered another bug,

Neil, read your patch carefully, I think it added the bug.

The ->page_offset of the frag gets applied two times.

skb_dma_map_frag() already takes frag->page_offset into consideration,
you then pass it in as the 'offset' argument and it then gets added to
itself to compute th final offset.
