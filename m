From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 3/5] drivers/atm/atmtcp.c: fix error return code
Date: Thu, 7 Aug 2014 15:31:05 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1408071530230.2337@hadrien>
References: <1407415749-19978-1-git-send-email-Julia.Lawall@lip6.fr> <1407415749-19978-3-git-send-email-Julia.Lawall@lip6.fr> <20140807091012.793ef5c7@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kernel-janitors@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140807091012.793ef5c7@thirdoffive.cmf.nrl.navy.mil>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Convert a zero return value on error to a negative one, as returned
elsewhere in the function.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
identifier ret; expression e1,e2;
@@
(
if (\(ret < 0\|ret != 0\))
 { ... return ret; }
|
ret = 0
)
... when != ret = e1
    when != &ret
*if(...)
{
  ... when != ret = e2
      when forall
 return ret;
}
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
v2; changed error code to -EUNATCH

 drivers/atm/atmtcp.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/atm/atmtcp.c b/drivers/atm/atmtcp.c
index 0e3f8f9..c8e4fb4 100644
--- a/drivers/atm/atmtcp.c
+++ b/drivers/atm/atmtcp.c
@@ -299,6 +299,7 @@ static int atmtcp_c_send(struct atm_vcc *vcc,struct sk_buff *skb)
 	out_vcc = find_vcc(dev, ntohs(hdr->vpi), ntohs(hdr->vci));
 	read_unlock(&vcc_sklist_lock);
 	if (!out_vcc) {
+		result = -EUNATCH;
 		atomic_inc(&vcc->stats->tx_err);
 		goto done;
 	}
