From: James Chapman <jchapman@katalix.com>
Subject: L2TP driver review
Date: Sun, 03 Jun 2007 18:17:03 +0100
Message-ID: <4662F78F.1080004@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:51104 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753605AbXFCRRI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Jun 2007 13:17:08 -0400
Received: from jchapman.plus.com ([84.92.108.75] helo=[192.168.1.10])
	by s36.avahost.net with esmtpa (Exim 4.63)
	(envelope-from <jchapman@katalix.com>)
	id 1Hutdq-0004ae-ES
	for netdev@vger.kernel.org; Sun, 03 Jun 2007 12:13:22 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've had no comments on the latest version of my L2TP driver which I 
posted a month ago. Can someone review it or accept/reject it, please? I 
have a pppd plugin that uses this driver and I'm eager to push it 
upstream for inclusion in the pppd distribution as soon as possible. But 
first, this L2TP driver needs to be accepted...

Thanks

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

-------- Original Message --------
Subject: resend [PATCH 0/5 2.6.21] L2TP: Introduce PPP-over-L2TP driver
Date: Sat, 26 May 2007 18:46:24 +0100
From: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org

On Patrick's request, I'm resending this patch set. There are no
changes since they were posted 3 weeks ago. Please review. Thanks.


This patch set adds a driver for PPP over L2TP. Patches to follow.

The following changes have been made since the previous version
submitted 23-APR-07.

- Hold list lock while processing reorder queue in
   pppol2tp_recv_dequeue().

- Fix more __be type annotations.

- Add a new UDP encapsulation socket type for L2TP (new patch). Modify
   driver receive path so that it hooks on udp_encap_rcv() rather than
   overload the socket's sk_data_ready() for skb reception.

- Remove pppol2tp_fget() and friends. Previous code needed to find the
   tunnel fd from a context other than the one that created the
   socket. I now use the PPPoX management socket creation (which is
   done by the same process that creates the UDP socket, i.e. l2tpd) to
   derive the socket of the UDP tunnel using sockfd_lookup().

- Reorder some functions in proc file handling code to avoid needing
   function prototypes.

- Remove code that sorted entries which are output in
   /proc/net/pppol2tp. Output now shows tunnels and sessions unordered.

- Remove stupid userland conditional includes from the if_pppox.h
   changes.

- Remove skb_queue_walk_safe and pppox-autoload patches from the
   series since they have now been applied.

- Add in-kernel documentation (new patch).

- Rebased to 2.6.21.

The code still uses sk->sk_destruct() on the tunnel socket to cleanup
internal contexts if the tunnel UDP socket is destroyed.


About this patch series:

The implementation uses the existing PPPoX subsystem that is currently
used only by PPPoE. A userspace daemon handles all L2TP control
protocol messages, while a PPPoX socket carries user data. The system
architecture is similar to PPPoE, where a pppd plugin uses the PPPoX
socket to send/receive PPP frames over an L2TP tunnel. PPP control
frames are delivered to pppd while data frames are handled entirely by
the kernel.

There are 5 patches in the series:-

1 - Introduce new UDP encapsulation type for L2TP.

2 - API changes for L2TP. Adds definitions for L2TP in existing headers.

3 - pppol2tp driver core. New code. Requires patches 1, 2, and the
     recently applied skb_queue_walk_safe patch.

4 - Add an entry to MAINTAINERS file for this driver.

5 - Add in-kernel documentation.

The driver is being used on x86, ia64, ppc, arm, mips32 and possibly
other architectures. It is also known to work on multi-core SMP boxes.

--
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development
-
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html


