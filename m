From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: =?UTF-8?q?=5BPATCH=5D=20Fix=20for=20possible=20null=20pointer=20dereference=20in=20auth=2Ec?=
Date: Thu, 15 May 2014 23:56:38 +0200
Message-ID: <1400190998-28153-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	"David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@primarydata.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is otherwise a risk of a possible null pointer dereference.

Was largely found by using a static code analysis program called cppche=
ck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital=
=2Ese>
---
 net/sunrpc/auth.c |   10 +++++++---
 1 fil =C3=A4ndrad, 7 till=C3=A4gg(+), 3 borttagningar(-)

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 5285ead..3a55698 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -801,10 +801,14 @@ rpcauth_invalcred(struct rpc_task *task)
 {
 	struct rpc_cred *cred =3D task->tk_rqstp->rq_cred;
=20
-	dprintk("RPC: %5u invalidating %s cred %p\n",
-		task->tk_pid, cred->cr_auth->au_ops->au_name, cred);
-	if (cred)
+	if (cred) {
+		dprintk("RPC: %5u invalidating %s cred %p\n",
+			task->tk_pid, cred->cr_auth->au_ops->au_name, cred);
+
 		clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
+	}
+	else
+		dprintk("RPC: %5u invalidating is NULL\n", task->tk_pid);
 }
=20
 int
--=20
1.7.10.4
