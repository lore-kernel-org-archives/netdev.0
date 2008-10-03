From: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
Subject: [PATCH 6/6] Phonet: pipe end-point protocol documentation
Date: Fri,  3 Oct 2008 17:09:39 +0300
Message-ID: <1223042979-21124-6-git-send-email-remi.denis-courmont@nokia.com>
References: <200810031709.11828.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:32376 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752246AbYJCOJs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2008 10:09:48 -0400
Received: from esebh105.NOE.Nokia.com (esebh105.ntc.nokia.com [172.21.138.211])
	by mgw-mx03.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m93E9MYP013730
	for <netdev@vger.kernel.org>; Fri, 3 Oct 2008 17:09:45 +0300
In-Reply-To: <200810031709.11828.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 Documentation/networking/phonet.txt |   54 +++++++++++++++++++++++++++=
++++++++
 1 files changed, 54 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/phonet.txt b/Documentation/networ=
king/phonet.txt
index 57d3e59..0e6e592 100644
--- a/Documentation/networking/phonet.txt
+++ b/Documentation/networking/phonet.txt
@@ -112,6 +112,60 @@ However, connect() and getpeername() are not suppo=
rted, as they did
 not seem useful with Phonet usages (could be added easily).
=20
=20
+Phonet Pipe protocol
+--------------------
+
+The Phonet Pipe protocol is a simple sequenced packets protocol
+with end-to-end congestion control. It uses the passive listening
+socket paradigm. The listening socket is bound to an unique free objec=
t
+ID. Each listening socket can handle up to 255 simultaneous
+connections, one per accept()'d socket.
+
+  int lfd, cfd;
+
+  lfd =3D socket(PF_PHONET, SOCK_SEQPACKET, PN_PROTO_PIPE);
+  listen (lfd, INT_MAX);
+
+  /* ... */
+  cfd =3D accept(lfd, NULL, NULL);
+  for (;;)
+  {
+    char buf[...];
+    ssize_t len =3D read(cfd, buf, sizeof(buf));
+
+    /* ... */
+
+    write(cfd, msg, msglen);
+  }
+
+Connections are established between two endpoints by a "third party"
+application. This means that both endpoints are passive; so connect()
+is not possible.
+
+WARNING:
+When polling a connected pipe socket for writability, there is an
+intrinsic race condition whereby writability might be lost between the
+polling and the writing system calls. In this case, the socket will
+block until write because possible again, unless non-blocking mode
+becomes enabled.
+
+
+The pipe protocol provides two socket options at the SOL_PNPIPE level:
+
+  PNPIPE_ENCAP accepts one integer value (int) of:
+
+    PNPIPE_ENCAP_NONE: The socket operates normally (default).
+
+    PNPIPE_ENCAP_IP: The socket is used as a backend for a virtual IP
+      interface. This requires CAP_NET_ADMIN capability. GPRS data
+      support on Nokia modems can use this. Note that the socket canno=
t
+      be reliably poll()'d or read() from while in this mode.
+
+  PNPIPE_IFINDEX is a read-only integer value. It contains the
+    interface index of the network interface created by PNPIPE_ENCAP,
+    or zero if encapsulation is off.
+
+
 Authors
 -------
=20
--=20
1.5.4.3

