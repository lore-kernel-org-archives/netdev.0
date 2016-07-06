From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Network hang after c3f1010b30f7fc611139cfb702a8685741aa6827 with
 CIPSO & Smack
Date: Tue, 5 Jul 2016 17:38:59 -0700
Message-ID: <e5ba1ba9-acf6-c36c-03e4-4cdc81e81648@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux-Netdev <netdev@vger.kernel.org>,
	Casey Schaufler <casey@schaufler-ca.com>
To: David Miller <davem@davemloft.net>, dsa@cumulusnetworks.com,
	Paul Moore <paul@paul-moore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm42-vm3.bullet.mail.bf1.yahoo.com ([216.109.114.190]:54617
	"EHLO nm42-vm3.bullet.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750840AbcGFAp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 20:45:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have encountered a system hang with my Smack
networking tests that bisects to the change below.
I can't say that I have any idea why the change
would impact the Smack processing, but there appears
to be some serious packet processing going on. The
Smack code is using CIPSO on the loopback interface.
The test is supposed to verify that labels can be
set on the packets using CIPSO. Unlabeled packets
do not appear to be impacted. I do not know if SELinux
is affected, and if not, why not. Smack and SELinux
use CIPSO differently.


c3f1010b30f7fc611139cfb702a8685741aa6827

commit c3f1010b30f7fc611139cfb702a8685741aa6827
Merge: ca4aa97 0b922b7
Author: David S. Miller <davem@davemloft.net>
Date:   Wed May 11 19:31:40 2016 -0400

    Merge branch 'vrf-pktinfo'
    
    David Ahern says:
    
    ====================
    net: vrf: Fixup PKTINFO to return enslaved device index
    
    Applications such as OSPF and BFD need the original ingress device not
    the VRF device; the latter can be derived from the former. To that end
    move the packet intercept from an rx handler that is invoked by
    __netif_receive_skb_core to the ipv4 and ipv6 receive processing.
    
    IPv6 already saves the skb_iif to the control buffer in ipv6_rcv. Since
    the skb->dev has not been switched the cb has the enslaved device. Make
    the same happen for IPv4 by adding the skb_iif to inet_skb_parm and set
    it in ipv4 code after clearing the skb control buffer similar to IPv6.
    From there the pktinfo can just pull it from cb with the PKTINFO_SKB_CB
    cast.
    ====================
    
    Signed-off-by: David S. Miller <davem@davemloft.net>
