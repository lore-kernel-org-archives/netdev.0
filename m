From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] net: sctp: Move sequence start handling into sctp_transport_get_idx()
Date: Fri, 15 Jan 2016 14:44:31 +0100
Message-ID: <1452865471-32509-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Xin Long <lucien.xin@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

net/sctp/proc.c: In function =E2=80=98sctp_transport_get_idx=E2=80=99:
net/sctp/proc.c:313: warning: =E2=80=98obj=E2=80=99 may be used uniniti=
alized in this function

This is currently a false positive, as all callers check for a zero
offset first, and handle this case in the exact same way.

Move the check and handling into sctp_transport_get_idx() to kill the
compiler warning, and avoid future bugs.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
Compile-tested only.
---
 net/sctp/proc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index dfa7eeccb5373053..684c5b31563badc1 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -310,7 +310,7 @@ static struct sctp_transport *sctp_transport_get_ne=
xt(struct seq_file *seq)
 static struct sctp_transport *sctp_transport_get_idx(struct seq_file *=
seq,
 						     loff_t pos)
 {
-	void *obj;
+	void *obj =3D SEQ_START_TOKEN;
=20
 	while (pos && (obj =3D sctp_transport_get_next(seq)) && !IS_ERR(obj))
 		pos--;
@@ -347,7 +347,7 @@ static void *sctp_assocs_seq_start(struct seq_file =
*seq, loff_t *pos)
 	if (err)
 		return ERR_PTR(err);
=20
-	return *pos ? sctp_transport_get_idx(seq, *pos) : SEQ_START_TOKEN;
+	return sctp_transport_get_idx(seq, *pos);
 }
=20
 static void sctp_assocs_seq_stop(struct seq_file *seq, void *v)
@@ -462,7 +462,7 @@ static void *sctp_remaddr_seq_start(struct seq_file=
 *seq, loff_t *pos)
 	if (err)
 		return ERR_PTR(err);
=20
-	return *pos ? sctp_transport_get_idx(seq, *pos) : SEQ_START_TOKEN;
+	return sctp_transport_get_idx(seq, *pos);
 }
=20
 static void *sctp_remaddr_seq_next(struct seq_file *seq, void *v, loff=
_t *pos)
--=20
1.9.1
