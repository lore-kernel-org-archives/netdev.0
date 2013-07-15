From: Paul Bolle <pebolle@tiscali.nl>
Subject: 9P: hook up rdma_cancelled() into p9_rdma_trans?
Date: Mon, 15 Jul 2013 10:44:05 +0200
Message-ID: <1373877845.2591.9.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Van Hensbergen <ericvh@gmail.com>,
	Ron Minnich <rminnich@sandia.gov>,
	Latchesar Ionkov <lucho@ionkov.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

0) Building trans_rdma.o (in v3.11-rc1) triggers a warning:
    net/9p/trans_rdma.c:594:12: warning: =E2=80=98rdma_cancelled=E2=80=99=
 defined but not used [-Wunused-function]

1) Did commit 80b45261a0 ("9P: Add cancelled() to the transport
functions.") forget to actually hook up rdma_cancelled() into
p9_rdma_trans()? Say, like this:

diff --git a/net/9p/trans_rdma.c b/net/9p/trans_rdma.c
index 928f2bb..0c42b1c 100644
--- a/net/9p/trans_rdma.c
+++ b/net/9p/trans_rdma.c
@@ -732,6 +732,7 @@ static struct p9_trans_module p9_rdma_trans =3D {
 	.close =3D rdma_close,
 	.request =3D rdma_request,
 	.cancel =3D rdma_cancel,
+	.cancelled =3D rdma_cancelled,
 };
=20
 /**

That (compile tested only) patch silences this warning. Is there a patc=
h
queued to do something like this? I couldn't find it.


Paul Bolle
