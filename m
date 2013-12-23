From: Chen Weilong <chenweilong@huawei.com>
Subject: [patch net-next v3 4/7] ipv4: fix all space errors in file igmp.c
Date: Mon, 23 Dec 2013 13:57:23 +0800
Message-ID: <1387778246-15300-5-git-send-email-chenweilong@huawei.com>
References: <1387778246-15300-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <netfilter-devel@vger.kernel.org>,
	<netfilter@vger.kernel.org>
To: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<steffen.klassert@secunet.com>, <herbert@gondor.apana.org.au>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <1387778246-15300-1-git-send-email-chenweilong@huawei.com>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Weilong Chen <chenweilong@huawei.com>

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 net/ipv4/igmp.c | 70 ++++++++++++++++++++++++++++-----------------------------
 1 file changed, 35 insertions(+), 35 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 7defdc9..84c4329 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -310,7 +310,7 @@ igmp_scount(struct ip_mc_list *pmc, int type, int gdeleted, int sdeleted)
 	struct ip_sf_list *psf;
 	int scount = 0;
 
-	for (psf=pmc->sources; psf; psf=psf->sf_next) {
+	for (psf = pmc->sources; psf; psf = psf->sf_next) {
 		if (!is_in(pmc, psf, type, gdeleted, sdeleted))
 			continue;
 		scount++;
@@ -463,7 +463,7 @@ static struct sk_buff *add_grec(struct sk_buff *skb, struct ip_mc_list *pmc,
 	}
 	first = 1;
 	psf_prev = NULL;
-	for (psf=*psf_list; psf; psf=psf_next) {
+	for (psf = *psf_list; psf; psf = psf_next) {
 		__be32 *psrc;
 
 		psf_next = psf->sf_next;
@@ -520,7 +520,7 @@ empty_source:
 			return skb;
 		if (pmc->crcount || isquery) {
 			/* make sure we have room for group header */
-			if (skb && AVAILABLE(skb)<sizeof(struct igmpv3_grec)) {
+			if (skb && AVAILABLE(skb) < sizeof(struct igmpv3_grec)) {
 				igmpv3_sendpack(skb);
 				skb = NULL; /* add_grhead will get a new one */
 			}
@@ -576,7 +576,7 @@ static void igmpv3_clear_zeros(struct ip_sf_list **ppsf)
 	struct ip_sf_list *psf_prev, *psf_next, *psf;
 
 	psf_prev = NULL;
-	for (psf=*ppsf; psf; psf = psf_next) {
+	for (psf = *ppsf; psf; psf = psf_next) {
 		psf_next = psf->sf_next;
 		if (psf->sf_crcount == 0) {
 			if (psf_prev)
@@ -600,7 +600,7 @@ static void igmpv3_send_cr(struct in_device *in_dev)
 
 	/* deleted MCA's */
 	pmc_prev = NULL;
-	for (pmc=in_dev->mc_tomb; pmc; pmc=pmc_next) {
+	for (pmc = in_dev->mc_tomb; pmc; pmc = pmc_next) {
 		pmc_next = pmc->next;
 		if (pmc->sfmode == MCAST_INCLUDE) {
 			type = IGMPV3_BLOCK_OLD_SOURCES;
@@ -764,7 +764,7 @@ static void igmp_ifc_event(struct in_device *in_dev)
 
 static void igmp_timer_expire(unsigned long data)
 {
-	struct ip_mc_list *im=(struct ip_mc_list *)data;
+	struct ip_mc_list *im = (struct ip_mc_list *)data;
 	struct in_device *in_dev = im->interface;
 
 	spin_lock(&im->lock);
@@ -794,10 +794,10 @@ static int igmp_xmarksources(struct ip_mc_list *pmc, int nsrcs, __be32 *srcs)
 	int i, scount;
 
 	scount = 0;
-	for (psf=pmc->sources; psf; psf=psf->sf_next) {
+	for (psf = pmc->sources; psf; psf = psf->sf_next) {
 		if (scount == nsrcs)
 			break;
-		for (i=0; i<nsrcs; i++) {
+		for (i = 0; i < nsrcs; i++) {
 			/* skip inactive filters */
 			if (psf->sf_count[MCAST_INCLUDE] ||
 			    pmc->sfcount[MCAST_EXCLUDE] !=
@@ -825,10 +825,10 @@ static int igmp_marksources(struct ip_mc_list *pmc, int nsrcs, __be32 *srcs)
 
 	/* mark INCLUDE-mode sources */
 	scount = 0;
-	for (psf=pmc->sources; psf; psf=psf->sf_next) {
+	for (psf = pmc->sources; psf; psf = psf->sf_next) {
 		if (scount == nsrcs)
 			break;
-		for (i=0; i<nsrcs; i++)
+		for (i = 0; i < nsrcs; i++)
 			if (srcs[i] == psf->sf_inaddr) {
 				psf->sf_gsresp = 1;
 				scount++;
@@ -1103,7 +1103,7 @@ static void igmpv3_add_delrec(struct in_device *in_dev, struct ip_mc_list *im)
 		pmc->tomb = im->tomb;
 		pmc->sources = im->sources;
 		im->tomb = im->sources = NULL;
-		for (psf=pmc->sources; psf; psf=psf->sf_next)
+		for (psf = pmc->sources; psf; psf = psf->sf_next)
 			psf->sf_crcount = pmc->crcount;
 	}
 	spin_unlock_bh(&im->lock);
@@ -1121,7 +1121,7 @@ static void igmpv3_del_delrec(struct in_device *in_dev, __be32 multiaddr)
 
 	spin_lock_bh(&in_dev->mc_tomb_lock);
 	pmc_prev = NULL;
-	for (pmc=in_dev->mc_tomb; pmc; pmc=pmc->next) {
+	for (pmc = in_dev->mc_tomb; pmc; pmc = pmc->next) {
 		if (pmc->multiaddr == multiaddr)
 			break;
 		pmc_prev = pmc;
@@ -1134,7 +1134,7 @@ static void igmpv3_del_delrec(struct in_device *in_dev, __be32 multiaddr)
 	}
 	spin_unlock_bh(&in_dev->mc_tomb_lock);
 	if (pmc) {
-		for (psf=pmc->tomb; psf; psf=psf_next) {
+		for (psf = pmc->tomb; psf; psf = psf_next) {
 			psf_next = psf->sf_next;
 			kfree(psf);
 		}
@@ -1167,7 +1167,7 @@ static void igmpv3_clear_delrec(struct in_device *in_dev)
 		psf = pmc->tomb;
 		pmc->tomb = NULL;
 		spin_unlock_bh(&pmc->lock);
-		for (; psf; psf=psf_next) {
+		for (; psf; psf = psf_next) {
 			psf_next = psf->sf_next;
 			kfree(psf);
 		}
@@ -1557,7 +1557,7 @@ static int ip_mc_del1_src(struct ip_mc_list *pmc, int sfmode,
 	int rv = 0;
 
 	psf_prev = NULL;
-	for (psf=pmc->sources; psf; psf=psf->sf_next) {
+	for (psf = pmc->sources; psf; psf = psf->sf_next) {
 		if (psf->sf_inaddr == *psfsrc)
 			break;
 		psf_prev = psf;
@@ -1630,7 +1630,7 @@ static int ip_mc_del_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
 		pmc->sfcount[sfmode]--;
 	}
 	err = 0;
-	for (i=0; i<sfcount; i++) {
+	for (i = 0; i < sfcount; i++) {
 		int rv = ip_mc_del1_src(pmc, sfmode, &psfsrc[i]);
 
 		changerec |= rv > 0;
@@ -1650,7 +1650,7 @@ static int ip_mc_del_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
 		pmc->crcount = in_dev->mr_qrv ? in_dev->mr_qrv :
 			IGMP_Unsolicited_Report_Count;
 		in_dev->mr_ifc_count = pmc->crcount;
-		for (psf=pmc->sources; psf; psf = psf->sf_next)
+		for (psf = pmc->sources; psf; psf = psf->sf_next)
 			psf->sf_crcount = 0;
 		igmp_ifc_event(pmc->interface);
 	} else if (sf_setstate(pmc) || changerec) {
@@ -1671,7 +1671,7 @@ static int ip_mc_add1_src(struct ip_mc_list *pmc, int sfmode,
 	struct ip_sf_list *psf, *psf_prev;
 
 	psf_prev = NULL;
-	for (psf=pmc->sources; psf; psf=psf->sf_next) {
+	for (psf = pmc->sources; psf; psf = psf->sf_next) {
 		if (psf->sf_inaddr == *psfsrc)
 			break;
 		psf_prev = psf;
@@ -1699,7 +1699,7 @@ static void sf_markstate(struct ip_mc_list *pmc)
 	struct ip_sf_list *psf;
 	int mca_xcount = pmc->sfcount[MCAST_EXCLUDE];
 
-	for (psf=pmc->sources; psf; psf=psf->sf_next)
+	for (psf = pmc->sources; psf; psf = psf->sf_next)
 		if (pmc->sfcount[MCAST_EXCLUDE]) {
 			psf->sf_oldin = mca_xcount ==
 				psf->sf_count[MCAST_EXCLUDE] &&
@@ -1716,7 +1716,7 @@ static int sf_setstate(struct ip_mc_list *pmc)
 	int new_in, rv;
 
 	rv = 0;
-	for (psf=pmc->sources; psf; psf=psf->sf_next) {
+	for (psf = pmc->sources; psf; psf = psf->sf_next) {
 		if (pmc->sfcount[MCAST_EXCLUDE]) {
 			new_in = mca_xcount == psf->sf_count[MCAST_EXCLUDE] &&
 				!psf->sf_count[MCAST_INCLUDE];
@@ -1726,7 +1726,7 @@ static int sf_setstate(struct ip_mc_list *pmc)
 			if (!psf->sf_oldin) {
 				struct ip_sf_list *prev = NULL;
 
-				for (dpsf=pmc->tomb; dpsf; dpsf=dpsf->sf_next) {
+				for (dpsf = pmc->tomb; dpsf; dpsf = dpsf->sf_next) {
 					if (dpsf->sf_inaddr == psf->sf_inaddr)
 						break;
 					prev = dpsf;
@@ -1748,7 +1748,7 @@ static int sf_setstate(struct ip_mc_list *pmc)
 			 * add or update "delete" records if an active filter
 			 * is now inactive
 			 */
-			for (dpsf=pmc->tomb; dpsf; dpsf=dpsf->sf_next)
+			for (dpsf = pmc->tomb; dpsf; dpsf = dpsf->sf_next)
 				if (dpsf->sf_inaddr == psf->sf_inaddr)
 					break;
 			if (!dpsf) {
@@ -1800,7 +1800,7 @@ static int ip_mc_add_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
 	if (!delta)
 		pmc->sfcount[sfmode]++;
 	err = 0;
-	for (i=0; i<sfcount; i++) {
+	for (i = 0; i < sfcount; i++) {
 		err = ip_mc_add1_src(pmc, sfmode, &psfsrc[i]);
 		if (err)
 			break;
@@ -1810,7 +1810,7 @@ static int ip_mc_add_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
 
 		if (!delta)
 			pmc->sfcount[sfmode]--;
-		for (j=0; j<i; j++)
+		for (j = 0; j < i; j++)
 			(void) ip_mc_del1_src(pmc, sfmode, &psfsrc[j]);
 	} else if (isexclude != (pmc->sfcount[MCAST_EXCLUDE] != 0)) {
 #ifdef CONFIG_IP_MULTICAST
@@ -1829,7 +1829,7 @@ static int ip_mc_add_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
 		pmc->crcount = in_dev->mr_qrv ? in_dev->mr_qrv :
 			IGMP_Unsolicited_Report_Count;
 		in_dev->mr_ifc_count = pmc->crcount;
-		for (psf=pmc->sources; psf; psf = psf->sf_next)
+		for (psf = pmc->sources; psf; psf = psf->sf_next)
 			psf->sf_crcount = 0;
 		igmp_ifc_event(in_dev);
 	} else if (sf_setstate(pmc)) {
@@ -1844,12 +1844,12 @@ static void ip_mc_clear_src(struct ip_mc_list *pmc)
 {
 	struct ip_sf_list *psf, *nextpsf;
 
-	for (psf=pmc->tomb; psf; psf=nextpsf) {
+	for (psf = pmc->tomb; psf; psf = nextpsf) {
 		nextpsf = psf->sf_next;
 		kfree(psf);
 	}
 	pmc->tomb = NULL;
-	for (psf=pmc->sources; psf; psf=nextpsf) {
+	for (psf = pmc->sources; psf; psf = nextpsf) {
 		nextpsf = psf->sf_next;
 		kfree(psf);
 	}
@@ -2043,7 +2043,7 @@ int ip_mc_source(int add, int omode, struct sock *sk, struct
 		if (!psl)
 			goto done;	/* err = -EADDRNOTAVAIL */
 		rv = !0;
-		for (i=0; i<psl->sl_count; i++) {
+		for (i = 0; i < psl->sl_count; i++) {
 			rv = memcmp(&psl->sl_addr[i], &mreqs->imr_sourceaddr,
 				sizeof(__be32));
 			if (rv == 0)
@@ -2062,7 +2062,7 @@ int ip_mc_source(int add, int omode, struct sock *sk, struct
 		ip_mc_del_src(in_dev, &mreqs->imr_multiaddr, omode, 1,
 			&mreqs->imr_sourceaddr, 1);
 
-		for (j=i+1; j<psl->sl_count; j++)
+		for (j = i+1; j < psl->sl_count; j++)
 			psl->sl_addr[j-1] = psl->sl_addr[j];
 		psl->sl_count--;
 		err = 0;
@@ -2088,7 +2088,7 @@ int ip_mc_source(int add, int omode, struct sock *sk, struct
 		newpsl->sl_max = count;
 		newpsl->sl_count = count - IP_SFBLOCK;
 		if (psl) {
-			for (i=0; i<psl->sl_count; i++)
+			for (i = 0; i < psl->sl_count; i++)
 				newpsl->sl_addr[i] = psl->sl_addr[i];
 			/* decrease mem now to avoid the memleak warning */
 			atomic_sub(IP_SFLSIZE(psl->sl_max), &sk->sk_omem_alloc);
@@ -2098,7 +2098,7 @@ int ip_mc_source(int add, int omode, struct sock *sk, struct
 		psl = newpsl;
 	}
 	rv = 1;	/* > 0 for insert logic below if sl_count is 0 */
-	for (i=0; i<psl->sl_count; i++) {
+	for (i = 0; i < psl->sl_count; i++) {
 		rv = memcmp(&psl->sl_addr[i], &mreqs->imr_sourceaddr,
 			sizeof(__be32));
 		if (rv == 0)
@@ -2106,7 +2106,7 @@ int ip_mc_source(int add, int omode, struct sock *sk, struct
 	}
 	if (rv == 0)		/* address already there is an error */
 		goto done;
-	for (j=psl->sl_count-1; j>=i; j--)
+	for (j = psl->sl_count-1; j >= i; j--)
 		psl->sl_addr[j+1] = psl->sl_addr[j];
 	psl->sl_addr[i] = mreqs->imr_sourceaddr;
 	psl->sl_count++;
@@ -2305,7 +2305,7 @@ int ip_mc_gsfget(struct sock *sk, struct group_filter *gsf,
 	    copy_to_user(optval, gsf, GROUP_FILTER_SIZE(0))) {
 		return -EFAULT;
 	}
-	for (i=0; i<copycount; i++) {
+	for (i = 0; i < copycount; i++) {
 		struct sockaddr_storage ss;
 
 		psin = (struct sockaddr_in *)&ss;
@@ -2350,7 +2350,7 @@ int ip_mc_sf_allow(struct sock *sk, __be32 loc_addr, __be32 rmt_addr, int dif)
 	if (!psl)
 		goto unlock;
 
-	for (i=0; i<psl->sl_count; i++) {
+	for (i = 0; i < psl->sl_count; i++) {
 		if (psl->sl_addr[i] == rmt_addr)
 			break;
 	}
@@ -2423,7 +2423,7 @@ int ip_check_mc_rcu(struct in_device *in_dev, __be32 mc_addr, __be32 src_addr, u
 		rv = 1;
 	} else if (im) {
 		if (src_addr) {
-			for (psf=im->sources; psf; psf=psf->sf_next) {
+			for (psf = im->sources; psf; psf = psf->sf_next) {
 				if (psf->sf_inaddr == src_addr)
 					break;
 			}
-- 
1.7.12


