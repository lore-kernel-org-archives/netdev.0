From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 3/4] [TCP]: Update comment of SACK block validator
Date: Mon,  1 Oct 2007 15:29:43 +0300
Message-ID: <11912417841037-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11912417841620-git-send-email-ilpo.jarvinen@helsinki.fi> <11912417843256-git-send-email-ilpo.jarvinen@helsinki.fi> <11912417843258-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35449 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751365AbXJAM3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 08:29:46 -0400
In-Reply-To: <11912417843258-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just came across what RFC2018 states about generation of valid
SACK blocks in case of reneging. Alter comment a bit to point
out clearly.

IMHO, there isn't any reason to change code because the
validation is there for a purpose (counters will inform user
about decision TCP made if this case ever surfaces).

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 135f046..cec2611 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1027,8 +1027,15 @@ static void tcp_update_reordering(struct sock *s=
k, const int metric,
  * SACK block range validation checks that the received SACK block fit=
s to
  * the expected sequence limits, i.e., it is between SND.UNA and SND.N=
XT.
  * Note that SND.UNA is not included to the range though being valid b=
ecause
- * it means that the receiver is rather inconsistent with itself (repo=
rts
- * SACK reneging when it should advance SND.UNA).
+ * it means that the receiver is rather inconsistent with itself repor=
ting
+ * SACK reneging when it should advance SND.UNA. Such SACK block this =
is
+ * perfectly valid, however, in light of RFC2018 which explicitly stat=
es
+ * that "SACK block MUST reflect the newest segment.  Even if the newe=
st
+ * segment is going to be discarded ...", not that it looks very cleve=
r
+ * in case of head skb. Due to potentional receiver driven attacks, we
+ * choose to avoid immediate execution of a walk in write queue due to
+ * reneging and defer head skb's loss recovery to standard loss recove=
ry
+ * procedure that will eventually trigger (nothing forbids us doing th=
is).
  *
  * Implements also blockage to start_seq wrap-around. Problem lies in =
the
  * fact that though start_seq (s) is before end_seq (i.e., not reverse=
d),
--=20
1.5.0.6

