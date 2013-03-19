From: Daniel Baluta <dbaluta@ixiacom.com>
Subject: [PATCH net-next] packet: Fix compile error
Date: Wed, 20 Mar 2013 00:01:21 +0200
Message-ID: <1363730481-7168-1-git-send-email-dbaluta@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Baluta <dbaluta@ixiacom.com>
To: willemb@google.com, edumazet@google.com, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:65533 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754872Ab3CSWBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 18:01:37 -0400
Received: by mail-bk0-f46.google.com with SMTP id j5so472503bkw.33
        for <netdev@vger.kernel.org>; Tue, 19 Mar 2013 15:01:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PACKET_FANOUT_ROLLOVER and PACKET_FANOUT_FLAG_ROLLOVER are not declared=
 in
<tree>/usr/include/linux/if_packet.h together with the other PACKET_FAN=
OUT_* macros
as one would expect. This causes the following compilation error:
<snip>
psock_fanout.c: In function =E2=80=98test_control_single=E2=80=99:
psock_fanout.c:230:23: error: =E2=80=98PACKET_FANOUT_ROLLOVER=E2=80=99 =
undeclared (first use in this function)
</snip>

Signed-off-by: Daniel Baluta <dbaluta@ixiacom.com>
---
 .../testing/selftests/net-afpacket/psock_fanout.c  |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/tools/testing/selftests/net-afpacket/psock_fanout.c b/tool=
s/testing/selftests/net-afpacket/psock_fanout.c
index 09dbf93..c827415 100644
--- a/tools/testing/selftests/net-afpacket/psock_fanout.c
+++ b/tools/testing/selftests/net-afpacket/psock_fanout.c
@@ -63,6 +63,7 @@
 #define PACKET_FANOUT_LB		1
 #define PACKET_FANOUT_CPU		2
 #define PACKET_FANOUT_FLAG_DEFRAG	0x8000
+#endif
=20
 #ifndef PACKET_FANOUT_ROLLOVER
 #define PACKET_FANOUT_ROLLOVER		3
@@ -72,8 +73,6 @@
 #define PACKET_FANOUT_FLAG_ROLLOVER	0x1000
 #endif
=20
-#endif
-
 #define DATA_LEN			100
 #define DATA_CHAR			'a'
=20
--=20
1.7.5.4
