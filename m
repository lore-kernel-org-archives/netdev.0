From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] gre: Avoid kernel panic by clearing IPCB before
 dst_link_failure called
Date: Wed, 17 Feb 2016 16:31:52 -0500 (EST)
Message-ID: <20160217.163152.1172947398779694144.davem@davemloft.net>
References: <1454990874-10497-1-git-send-email-bernie.harris@alliedtelesis.co.nz>
	<1455585016-7253-1-git-send-email-bernie.harris@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	stable@vger.kernel.org
To: bernie.harris@alliedtelesis.co.nz
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1455585016-7253-1-git-send-email-bernie.harris@alliedtelesis.co.nz>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bernie Harris <bernie.harris@alliedtelesis.co.nz>
Date: Tue, 16 Feb 2016 14:10:16 +1300

> skb->cb may contain data from previous layers (in the observed case the
> qdisc layer). In the observed scenario, the data was misinterpreted as
> ip header options, which later caused the ihl to be set to an invalid
> value (<5). This resulted in an infinite loop in the mips implementation
> of ip_fast_csum.
> 
> This patch clears IPCB before dst_link_failure is called from the functions
> ip_tunnel_xmit and ip6gre_xmit2, similar to what commit 11c21a30 does for
> an ipv4 case.
> 
> Signed-off-by: Bernie Harris <bernie.harris@alliedtelesis.co.nz>

Again, I want to see this implemented in a way which causes things to be
treated consistently across all tunneling types.

Which means fixing the exact problem, IPCB(skb)->opt needing initilization.

Thanks.
