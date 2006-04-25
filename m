From: Hua Zhong <hzhong@gmail.com>
Subject: [PATCH] remove likely in ip_rcv_finish()
Date: Tue, 25 Apr 2006 02:10:27 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0604250204470.4481@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <netdev-owner@vger.kernel.org>
Received: from wproxy.gmail.com ([64.233.184.232]:20126 "EHLO wproxy.gmail.com")
	by vger.kernel.org with ESMTP id S932154AbWDYJL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2006 05:11:59 -0400
Received: by wproxy.gmail.com with SMTP id 69so906812wra
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2006 02:11:59 -0700 (PDT)
To: davem@savemloft.net, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This is another result from my likely profiling tool (dwalker@mvista.com just sent the patch of the profiling tool to linux-kernel mailing list, which is similar to what I use).

On my system (not very busy, normal development machine within a VMWare workstation), I see a 6/5 miss/hit ratio for the following "likely".

I am not sure what would happen for a busy system though (on which performance actually matters), but I am just reporting what I find and hope it might help.

Signed-off-by: Hua Zhong <hzhong@gmail.com>

diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 18d7fad..9f44359 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -337,7 +337,7 @@ static inline int ip_rcv_finish(struct s
  	 *	Initialise the virtual path cache for the packet. It describes
  	 *	how the packet travels inside Linux networking.
  	 */ 
-	if (likely(skb->dst == NULL)) {
+	if (skb->dst) {
  		int err = ip_route_input(skb, iph->daddr, iph->saddr, iph->tos,
  					 skb->dev);
  		if (unlikely(err)) {
