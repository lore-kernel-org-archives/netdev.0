From: =?ISO-8859-2?Q?T=F3th_L=E1szl=F3_Attila?= <panther@balabit.hu>
Subject: UDPv4 port allocation problem
Date: Thu, 23 Aug 2007 09:16:50 +0200
Message-ID: <46CD3462.2070403@balabit.hu>
Reply-To: panther@balabit.hu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:2616 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754973AbXHWHpr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2007 03:45:47 -0400
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 08892C11CA
	for <netdev@vger.kernel.org>; Thu, 23 Aug 2007 09:16:57 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I noticed that it is possible that the kernel allocates the same UDP
port to an application that was used and closed immediately before the
new application got it. This means that applications that do not specify
an exact port and rely on the  kernel to allocate a port for them might
see traffic originally meant for another application.

Imagine that two applications want to resolve a name in DNS at about the
same time. The following happens:
 * first app sends out the DNS query then closes the socket without
waiting for an answer (e.g. it got interrupted by Ctrl+C)
 * second app opens an UDP socket, and gets the same port, originally
assigned to app#1, sends out the DNS query
 * DNS server responds, the response goes to app#2

DNS might not be the perfect example, but you get the idea. 
Applications do not expect to receive data on newly opened sockets, not
to mention the security implications.

TCP on the other hand increases the allocated port number for each new
socket, the same behaviour for UDP would add certain amount of time that
decreases this risk.

Is the current behaviour intended?

Regards,
Laszlo Attila Toth
