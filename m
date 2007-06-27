From: Steve Wise <swise@opengridcomputing.com>
Subject: [ofa-general] [PATCH 6/6] iw_cxgb3: Don't abort after failures
	sending the mpa reply.
Date: Wed, 27 Jun 2007 10:51:50 -0500
Message-ID: <20070627155150.24944.36124.stgit@dell3.ogc.int>
References: <20070627155119.24944.44172.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, divy@chelsio.com, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070627155119.24944.44172.stgit@dell3.ogc.int>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org


iw_cxgb3: Don't abort after failures sending the mpa reply.

This bug results in an abort request being sent down _after_ the tid
has been released.  If the tid happens to have been reused, then the
subsequent generation of the tid gets incorrectly aborted.

The thread running iwch_accecpt_cr() must not abort a connection if an
error is returned after being awakened.  If any errors did occur while
iwch_accept_cr() is blocked, then the connection has already been aborted
on the thread processing the error.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/cxgb3/iwch_cm.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/h=
w/cxgb3/iwch_cm.c
index 228721f..3b41dc0 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -1781,7 +1781,6 @@ err:
 	ep->com.cm_id =3D NULL;
 	ep->com.qp =3D NULL;
 	cm_id->rem_ref(cm_id);
-	abort_connection(ep, NULL, GFP_KERNEL);
 	put_ep(&ep->com);
 	return err;
 }
