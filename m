From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC PATCH 7/8] [SCTP]: uninline sctp_add_cmd_sf
Date: Wed, 20 Feb 2008 15:47:17 +0200
Message-ID: <1203515238-22848-8-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1203515238-22848-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-5-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-6-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-7-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:37181 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754740AbYBTNrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 08:47:21 -0500
In-Reply-To: <1203515238-22848-7-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I added inline to sctp_add_cmd and appropriate comment there to
avoid adding another call into the call chain. This works at least
with "gcc (GCC) 4.1.2 20070626 (Red Hat 4.1.2-13)". Alternatively,
__sctp_add_cmd could be introduced to .h.

net/sctp/sm_statefuns.c:
  sctp_sf_cookie_wait_prm_abort      | -125
  sctp_sf_cookie_wait_prm_shutdown   |  -75
  sctp_sf_do_9_1_prm_abort           |  -75
  sctp_sf_shutdown_sent_prm_abort    |  -50
  sctp_sf_pdiscard                   |  -25
  sctp_stop_t1_and_abort             | -100
  sctp_sf_do_9_2_start_shutdown      | -154
  __sctp_sf_do_9_1_abort             |  -50
  sctp_send_stale_cookie_err         |  -29
  sctp_sf_abort_violation            | -181
  sctp_sf_do_9_2_shutdown_ack        | -154
  sctp_sf_do_9_2_reshutack           |  -86
  sctp_sf_tabort_8_4_8               |  -28
  sctp_sf_heartbeat                  |  -52
  sctp_sf_shut_8_4_5                 |  -27
  sctp_eat_data                      | -246
  sctp_sf_shutdown_sent_abort        |  -58
  sctp_sf_check_restart_addrs        |  -50
  sctp_sf_do_unexpected_init         | -110
  sctp_sf_sendbeat_8_3               | -107
  sctp_sf_unk_chunk                  |  -65
  sctp_sf_do_prm_asoc                | -129
  sctp_sf_do_prm_send                |  -25
  sctp_sf_do_9_2_prm_shutdown        |  -50
  sctp_sf_error_closed               |  -25
  sctp_sf_error_shutdown             |  -25
  sctp_sf_shutdown_pending_prm_abort |  -25
  sctp_sf_do_prm_requestheartbeat    |  -28
  sctp_sf_do_prm_asconf              |  -75
  sctp_sf_do_6_3_3_rtx               | -104
  sctp_sf_do_6_2_sack                |  -25
  sctp_sf_t1_init_timer_expire       | -133
  sctp_sf_t1_cookie_timer_expire     | -104
  sctp_sf_t2_timer_expire            | -161
  sctp_sf_t4_timer_expire            | -175
  sctp_sf_t5_timer_expire            |  -75
  sctp_sf_autoclose_timer_expire     |  -50
  sctp_sf_do_5_2_4_dupcook           | -579
  sctp_sf_do_4_C                     | -125
  sctp_sf_shutdown_pending_abort     |  -32
  sctp_sf_do_5_1E_ca                 | -186
  sctp_sf_backbeat_8_3               |  -27
  sctp_sf_cookie_echoed_err          | -300
  sctp_sf_eat_data_6_2               | -146
  sctp_sf_eat_data_fast_4_4          | -125
  sctp_sf_eat_sack_6_2               |  -29
  sctp_sf_operr_notify               |  -25
  sctp_sf_do_9_2_final               | -152
  sctp_sf_do_asconf                  |  -64
  sctp_sf_do_asconf_ack              | -284
  sctp_sf_eat_fwd_tsn_fast           | -160
  sctp_sf_eat_auth                   |  -86
  sctp_sf_do_5_1B_init               | -110
  sctp_sf_do_5_1C_ack                | -204
  sctp_sf_do_9_2_shutdown            |  -78
  sctp_sf_do_ecn_cwr                 |  -24
  sctp_sf_do_ecne                    |  -32
  sctp_sf_eat_fwd_tsn                | -135
  sctp_sf_do_5_1D_ce                 | -197
  sctp_sf_beat_8_3                   |  -28
 60 functions changed, 6184 bytes removed, diff: -6184
net/sctp/sm_sideeffect.c:
  sctp_side_effects | -3873
  sctp_do_sm        | +3429
 2 functions changed, 3429 bytes added, 3873 bytes removed, diff: -444
kernel/uninlined.c:
  sctp_add_cmd_sf                   |  +35
 1 function changed, 35 bytes added, diff: +35

vmlinux.o:
 63 functions changed, 3464 bytes added, 10057 bytes removed, diff: -65=
93

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/sm.h |    8 ++------
 net/sctp/command.c    |   12 +++++++++++-
 2 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index ef9e7ed..6740b11 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -385,13 +385,9 @@ static inline int ADDIP_SERIAL_gte(__u16 s, __u16 =
t)
 	return (((s) =3D=3D (t)) || (((t) - (s)) & ADDIP_SERIAL_SIGN_BIT));
 }
=20
-
 /* Run sctp_add_cmd() generating a BUG() if there is a failure.  */
-static inline void sctp_add_cmd_sf(sctp_cmd_seq_t *seq, sctp_verb_t ve=
rb, sctp_arg_t obj)
-{
-	if (unlikely(!sctp_add_cmd(seq, verb, obj)))
-		BUG();
-}
+extern void sctp_add_cmd_sf(sctp_cmd_seq_t *seq, sctp_verb_t verb,
+			    sctp_arg_t obj);
=20
 /* Check VTAG of the packet matches the sender's own tag. */
 static inline int
diff --git a/net/sctp/command.c b/net/sctp/command.c
index bb97733..187da2d 100644
--- a/net/sctp/command.c
+++ b/net/sctp/command.c
@@ -51,8 +51,11 @@ int sctp_init_cmd_seq(sctp_cmd_seq_t *seq)
=20
 /* Add a command to a sctp_cmd_seq_t.
  * Return 0 if the command sequence is full.
+ *
+ * Inline here is not a mistake, this way sctp_add_cmd_sf doesn't need=
 extra
+ * calls, size penalty is of insignificant magnitude here
  */
-int sctp_add_cmd(sctp_cmd_seq_t *seq, sctp_verb_t verb, sctp_arg_t obj=
)
+inline int sctp_add_cmd(sctp_cmd_seq_t *seq, sctp_verb_t verb, sctp_ar=
g_t obj)
 {
 	if (seq->next_free_slot >=3D SCTP_MAX_NUM_COMMANDS)
 		goto fail;
@@ -66,6 +69,13 @@ fail:
 	return 0;
 }
=20
+/* Run sctp_add_cmd() generating a BUG() if there is a failure.  */
+void sctp_add_cmd_sf(sctp_cmd_seq_t *seq, sctp_verb_t verb, sctp_arg_t=
 obj)
+{
+	if (unlikely(!sctp_add_cmd(seq, verb, obj)))
+		BUG();
+}
+
 /* Return the next command structure in a sctp_cmd_seq.
  * Returns NULL at the end of the sequence.
  */
--=20
1.5.2.2

