From: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
Subject: Telnet closing delay
Date: Tue, 1 May 2007 22:48:11 +0200
Message-ID: <3C59DB883F7B0B4D8096010D45ACCD1323004D@exch.facton.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.facton.com ([83.236.152.122]:50748 "EHLO alpha.facton.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1945948AbXEAUxV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2007 16:53:21 -0400
Received: from exch.facton.local (exch [192.168.200.5])
	by alpha.facton.com (8.13.8/8.13.8/FACTON) with ESMTP id l41KmBwj019960
	for <netdev@vger.kernel.org>; Tue, 1 May 2007 22:48:11 +0200
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since 2.6.21 I often got a 2 seconds delay when closing a telnet session
to such a machine (even to localhost).
I was at least not aware of this with older versions, but maybe I'm
wrong?!?

Client with delay:

0.000062 select(4, [0 3], [], [3], NULL) = 1 (in [3])
1.803057 recvfrom(3, "", 8192, 0, NULL, NULL) = 0

without delay:

0.000061 select(4, [0 3], [], [3], NULL) = 1 (in [3])
0.001491 recvfrom(3, "", 8192, 0, NULL, NULL) = 0

Server with delay:

0.000095 select(4, [0 3], [], [0], NULL) = 1 (in [3])
0.001779 read(3, 0x8059de0, 8192)  = -1 EIO (Input/output error)
0.000103 select(4, [0 3], [], [0], NULL) = 1 (in [3])
0.000171 read(3, 0x8059de0, 8192)  = -1 EIO (Input/output error)
 ---- and 10000 lines more of this select/read----
0.000103 select(4, [0 3], [], [0], NULL) = 1 (in [3])
0.000343 --- SIGCHLD (Child exited) @ 0 (0) ---

without delay:

0.000100 select(4, [0 3], [], [0], NULL) = 1 (in [3])
0.001757 --- SIGCHLD (Child exited) @ 0 (0) ---

Daniel
