From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] tunnel: Clear IPCB(skb)->opt before
 dst_link_failure called
Date: Tue, 23 Feb 2016 19:12:21 -0500 (EST)
Message-ID: <20160223.191221.211549664974307758.davem@davemloft.net>
References: <1455585016-7253-1-git-send-email-bernie.harris@alliedtelesis.co.nz>
	<1456099085-24097-1-git-send-email-bernie.harris@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	stable@vger.kernel.org
To: bernie.harris@alliedtelesis.co.nz
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1456099085-24097-1-git-send-email-bernie.harris@alliedtelesis.co.nz>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bernie Harris <bernie.harris@alliedtelesis.co.nz>
Date: Mon, 22 Feb 2016 12:58:05 +1300

> IPCB may contain data from previous layers (in the observed case the
> qdisc layer). In the observed scenario, the data was misinterpreted as
> ip header options, which later caused the ihl to be set to an invalid
> value (<5). This resulted in an infinite loop in the mips implementation
> of ip_fast_csum.
> 
> This patch clears IPCB(skb)->opt before dst_link_failure can be called for
> various types of tunnels. This change only applies to encapsulated ipv4
> packets.
> 
> The code introduced in 11c21a30 which clears all of IPCB has been removed
> to be consistent with these changes, and instead the opt field is cleared
> unconditionally in ip_tunnel_xmit. The change in ip_tunnel_xmit applies to
> SIT, GRE, and IPIP tunnels.
> 
> The relevant vti, l2tp, and pptp functions already contain similar code for
> clearing the IPCB.
> 
> Signed-off-by: Bernie Harris <bernie.harris@alliedtelesis.co.nz>

Applied and queued up for -stable, thanks!
