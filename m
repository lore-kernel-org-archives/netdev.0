From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp/dccp: fix old style declarations
Date: Thu, 01 Oct 2015 04:48:53 -0700
Message-ID: <1443700133.32531.39.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Raanan Avargil <raanan.avargil@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33439 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752706AbbJALsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 07:48:55 -0400
Received: by pacex6 with SMTP id ex6so72911943pac.0
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2015 04:48:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Raanan Avargil <raanan.avargil@intel.com>

I=E2=80=99m using the compilation flag -Werror=3Dold-style-declaration,=
 which
requires that the =E2=80=9Cinline=E2=80=9D word would come at the begin=
ning of the code
line.
=20
$ make drivers/net/ethernet/intel/e1000e/e1000e.ko
=2E..
include/net/inet_timewait_sock.h:116:1: error: =E2=80=98inline=E2=80=99=
 is not at
beginning of declaration [-Werror=3Dold-style-declaration]
static void inline inet_twsk_schedule(struct inet_timewait_sock *tw, in=
t
timeo)

include/net/inet_timewait_sock.h:121:1: error: =E2=80=98inline=E2=80=99=
 is not at
beginning of declaration [-Werror=3Dold-style-declaration]
static void inline inet_twsk_reschedule(struct inet_timewait_sock *tw,
int timeo)

=46ixes: ed2e92394589 ("tcp/dccp: fix timewait races in timer handling"=
)
Signed-off-by: Raanan Avargil <raanan.avargil@intel.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet_timewait_sock.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewa=
it_sock.h
index 186f3a1e1b1f..fc1937698625 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -113,12 +113,12 @@ void __inet_twsk_hashdance(struct inet_timewait_s=
ock *tw, struct sock *sk,
 void __inet_twsk_schedule(struct inet_timewait_sock *tw, int timeo,
 			  bool rearm);
=20
-static void inline inet_twsk_schedule(struct inet_timewait_sock *tw, i=
nt timeo)
+static inline void inet_twsk_schedule(struct inet_timewait_sock *tw, i=
nt timeo)
 {
 	__inet_twsk_schedule(tw, timeo, false);
 }
=20
-static void inline inet_twsk_reschedule(struct inet_timewait_sock *tw,=
 int timeo)
+static inline void inet_twsk_reschedule(struct inet_timewait_sock *tw,=
 int timeo)
 {
 	__inet_twsk_schedule(tw, timeo, true);
 }
