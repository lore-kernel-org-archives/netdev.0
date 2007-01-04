From: Raivis Bucis <raivis@mt.lv>
Subject: [BUG] problem with BPF in PF_PACKET sockets, introduced in linux-2.6.19
Date: Thu, 4 Jan 2007 17:47:46 +0200
Message-ID: <200701041747.46358.raivis@mt.lv>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: waltje@uWalt.NL.Mugnet.ORG, gw4pts@gw4pts.ampr.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bute.mt.lv ([159.148.172.196]:58061 "EHLO bute.mt.lv"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965000AbXADQPh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jan 2007 11:15:37 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I believe I have found a bug in PF_PACKET socket filtering (introduced in 
linux-2.6.19). If BPF returns values larger than 0x80000000u, run_filter in 
af_packet.c considers that as error instead of simply accepting packet in its 
full length. sk_filter does not have this problem.

Raivis Bucis

Index: linux-2.6.19/net/packet/af_packet.c
===================================================================
--- linux-2.6.19/net/packet/af_packet.c
+++ linux-2.6.19/net/packet/af_packet.c
@@ -447,6 +447,8 @@
                        err = -EPERM;
                else if (*snaplen > err)
                        *snaplen = err;
+               else
+                       err = *snaplen;
        }
        rcu_read_unlock_bh();
 
