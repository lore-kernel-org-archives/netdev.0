From: Maxime Bizon <mbizon@freebox.fr>
Subject: problem forwarding IP fragments with DF bit set (caused by ipv4:
 fix path MTU discovery with connection tracking)
Date: Mon, 28 Apr 2014 18:37:36 +0200
Message-ID: <1398703056.12635.41.camel@sakura.staff.proxad.net>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.iliad.fr ([212.27.33.1]:54068 "EHLO ns.iliad.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932882AbaD1Qhi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2014 12:37:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello Patrick & Eric,

After upgrading a router with a kernel that has patch 5f2d04f1f9 (ipv4:
fix path MTU discovery with connection tracking), some packets are not
forwarded anymore.

(note: kernel is 3.11.10, and conntrack is enabled)

Offending packets are IP fragments with DF bit set, MTU is the same on
both interfaces involved in forwarding. All received fragments are
(obviously) below MTU. The resulting packet after re-assembly is however
above MTU.

conntrack causes the packets to be re-assembled, but since the resulting
skb now has IP_DF set, it fails the (DF + MTU) test in ip_forward.c and
causes ICMP frag_needed to be sent.

Without the patch, the packet was (re-)fragmented in the output path
(but as the patch says, breaking PMTUD because original fragment size is
not considered).

-- 
Maxime
