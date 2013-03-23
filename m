From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Atheros Communications Inc. AR8121/AR8113/AR8114 Gigabit or Fast Ethernet (rev b0) 1.0.0.7 md5/sha1 corrupted using NFS and samba (updated) Version 2
Date: Sat, 23 Mar 2013 03:10:08 +0100
Message-ID: <20130323021008.GC939@order.stressinduktion.org>
References: <514CE440.3010003@gmail.com> <1363996448.4431.73.camel@edumazet-glaptop> <514CF23A.3010702@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: rebelyouth <rebelyouth.hacklab@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:53189 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422826Ab3CWCKJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 22:10:09 -0400
Content-Disposition: inline
In-Reply-To: <514CF23A.3010702@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 22, 2013 at 08:07:22PM -0400, rebelyouth wrote:
> On 22/03/13 07:54 PM, Eric Dumazet wrote:
> >On Fri, 2013-03-22 at 19:07 -0400, rebelyouth wrote:
> >>Hi,
> >>
> >>I'm writing again for the same issue about :
> >>
> >Your mail is so long that we are lost.
> >
> >Have you done some research to tell if the bug is :
> >
> >1) Sending corrupt frames
> >
> >2) receive corrupt frames
> >
> >
> Hi Eric and Hannes,
> 
> The server receiver errors  when I use the atheros:
> 
> RX packets:78125369 errors:58741 dropped:0 overruns:58741 frame:0
> 
> but on the client side  there aren't any error but the file  is corrupted
> 
> I rebooted  the server and did the test with the Realtek:
> 
>  file ok , no errors in both sides
> 
> I also reset again the server and did a test on windows using samba and 
> the Atheros:
> 
>  file ok , no errors in both sides

Could you try this patch? It solves the problem with an atl1e nic on my
friends computer. This does not solve the real problem, which I have
not yet understood (wrong packets will be discarded now and will be
hopefully resend).

[PATCH RFC] atl1e: don't rely on hardware checksumming

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
index e1f1b2a..0363e5b 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -1337,6 +1337,8 @@ static inline void atl1e_rx_checksum(struct atl1e_adapter *adapter,
 	u16 err_flags;
 
 	skb_checksum_none_assert(skb);
+	goto hw_xsum;
+
 	pkt_flags = prrs->pkt_flag;
 	err_flags = prrs->err_flag;
 	if (((pkt_flags & RRS_IS_IPV4) || (pkt_flags & RRS_IS_IPV6)) &&
-- 
1.8.1.4
