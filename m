From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 19 Aug 2008 08:27:37 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808190806120.4551@wrl-59.cs.helsinki.fi>
References: <20080818.165411.255925269.davem@davemloft.net>
 <20080819000551.GA26699@gondor.apana.org.au> <20080818.171124.192743795.davem@davemloft.net>
 <20080818.210701.80578862.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1995621775-1219123657=:4551"
Cc: Herbert Xu <herbert@gondor.apana.org.au>, jarkao2@gmail.com,
	Netdev <netdev@vger.kernel.org>, denys@visp.net.lb
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46359 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752482AbYHSF1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 01:27:39 -0400
In-Reply-To: <20080818.210701.80578862.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1995621775-1219123657=:4551
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 18 Aug 2008, David Miller wrote:

> From: David Miller <davem@davemloft.net>
> Date: Mon, 18 Aug 2008 17:11:24 -0700 (PDT)
> 
> Ok, here it is.  I'll push this out to net-2.6 after I do
> some testing here.
> 
> pkt_sched: Don't hold qdisc lock over qdisc_destroy().

...snip...

> @@ -1092,16 +1089,10 @@ create_n_graft:
>  
>  graft:
>  	if (1) {
> -		spinlock_t *root_lock;
> -
>  		err = qdisc_graft(dev, p, skb, n, clid, q, NULL);

After this the block became unnecessary...

-- 
 i.


--
[PATCH] pkt_sched: remove bogus block (cleanup)

...Last block local var got just deleted.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/sched/sch_api.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index d91a233..9372ec4 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1088,14 +1088,13 @@ create_n_graft:
 	}
 
 graft:
-	if (1) {
-		err = qdisc_graft(dev, p, skb, n, clid, q, NULL);
-		if (err) {
-			if (q)
-				qdisc_destroy(q);
-			return err;
-		}
+	err = qdisc_graft(dev, p, skb, n, clid, q, NULL);
+	if (err) {
+		if (q)
+			qdisc_destroy(q);
+		return err;
 	}
+
 	return 0;
 }
 
-- 
1.5.2.2

---696208474-1995621775-1219123657=:4551--
