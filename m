From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: ppp_generic.c severly whitespace damanged by
	9c705260feea6ae329bc6b6d5f6d2ef0227eda0a
Date: Mon, 18 Jan 2010 17:59:55 -0500
Message-ID: <20100118225955.GA24307@caffeine.csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gabriele Paoloni <gabriele.paoloni@intel.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Len Sorensen <lsorense@csclub.uwaterloo.ca>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.csclub.uwaterloo.ca ([129.97.134.17]:44794 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756459Ab0ARW74 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 17:59:56 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was just looking at ppp_generic, and noticed that it fairly recently
(as in the last year) got rather mangled with many spaces turned into tabs
in places they very much shouldn't have been.  I tracked it down to commit
9c705260feea6ae329bc6b6d5f6d2ef0227eda0a (ppp: ppp_mp_explode() redesign).

I am amazed if that patch passed the patch checking script.  I have no
idea what kind of weird editor setting did this, but it has to have been a
weird editor setting or a very unfortunate search and replace gone wrong.
I only found it trying to apply a patch I was playing with and wondering
why it wouldn't apply.  Then I found there were tabs in the middle of
comments that used to be spaces.

Well here is a patch that should fix it up as far as I can tell.

Purely whitespace repair.  No actual code changes.

Signed-off-by: Len Sorensen <lsorense@csclub.uwaterloo.ca>

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 2282e72..6d61602 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -167,7 +167,7 @@ struct channel {
 	u8		avail;		/* flag used in multilink stuff */
 	u8		had_frag;	/* >= 1 fragments have been sent */
 	u32		lastseq;	/* MP: last sequence # received */
-	int     speed;		/* speed of the corresponding ppp channel*/
+	int		speed;		/* speed of the corresponding ppp channel*/
 #endif /* CONFIG_PPP_MULTILINK */
 };
 
@@ -1293,13 +1293,13 @@ ppp_push(struct ppp *ppp)
  */
 static int ppp_mp_explode(struct ppp *ppp, struct sk_buff *skb)
 {
-	int	len, totlen;
-	int	i, bits, hdrlen, mtu;
-	int	flen;
-	int	navail,	nfree, nzero;
-	int	nbigger;
-	int	totspeed;
-	int	totfree;
+	int len, totlen;
+	int i, bits, hdrlen, mtu;
+	int flen;
+	int navail, nfree, nzero;
+	int nbigger;
+	int totspeed;
+	int totfree;
 	unsigned char *p, *q;
 	struct list_head *list;
 	struct channel *pch;
@@ -1307,21 +1307,21 @@ static int ppp_mp_explode(struct ppp *ppp, struct sk_buff *skb)
 	struct ppp_channel *chan;
 
 	totspeed = 0; /*total bitrate of the bundle*/
-	nfree =	0;	/* # channels which	have no	packet already queued */
-	navail = 0;	/* total # of usable channels (not deregistered) */
-	nzero =	0; /* number of	channels with zero speed associated*/
-	totfree	= 0; /*total # of channels available and
+	nfree = 0; /* # channels which have no packet already queued */
+	navail = 0; /* total # of usable channels (not deregistered) */
+	nzero = 0; /* number of channels with zero speed associated*/
+	totfree = 0; /*total # of channels available and
 				  *having no queued packets before
 				  *starting the fragmentation*/
 
 	hdrlen = (ppp->flags & SC_MP_XSHORTSEQ)? MPHDRLEN_SSN: MPHDRLEN;
-	i =	0;
-	list_for_each_entry(pch, &ppp->channels, clist)	{
+	i = 0;
+	list_for_each_entry(pch, &ppp->channels, clist) {
 		navail += pch->avail = (pch->chan != NULL);
 		pch->speed = pch->chan->speed;
-		if (pch->avail)	{
+		if (pch->avail) {
 			if (skb_queue_empty(&pch->file.xq) ||
-				!pch->had_frag)	{
+				!pch->had_frag) {
 					if (pch->speed == 0)
 						nzero++;
 					else
@@ -1331,60 +1331,60 @@ static int ppp_mp_explode(struct ppp *ppp, struct sk_buff *skb)
 					++nfree;
 					++totfree;
 				}
-			if (!pch->had_frag && i	< ppp->nxchan)
-				ppp->nxchan	= i;
+			if (!pch->had_frag && i < ppp->nxchan)
+				ppp->nxchan = i;
 		}
 		++i;
 	}
 	/*
-	 * Don't start sending this	packet unless at least half	of
-	 * the channels	are	free.  This	gives much better TCP
-	 * performance if we have a	lot	of channels.
+	 * Don't start sending this packet unless at least half of
+	 * the channels are free.  This gives much better TCP
+	 * performance if we have a lot of channels.
 	 */
-	if (nfree == 0 || nfree	< navail / 2)
-		return 0; /* can't take now, leave it in xmit_pending	*/
+	if (nfree == 0 || nfree < navail / 2)
+		return 0; /* can't take now, leave it in xmit_pending */
 
 	/* Do protocol field compression (XXX this should be optional) */
-	p =	skb->data;
-	len	= skb->len;
+	p = skb->data;
+	len = skb->len;
 	if (*p == 0) {
 		++p;
 		--len;
 	}
 
 	totlen = len;
-	nbigger	= len %	nfree;
+	nbigger = len % nfree;
 
-	/* skip	to the channel after the one we	last used
-	   and start at	that one */
+	/* skip to the channel after the one we last used
+	   and start at that one */
 	list = &ppp->channels;
-	for	(i = 0;	i <	ppp->nxchan; ++i) {
+	for (i = 0; i < ppp->nxchan; ++i) {
 		list = list->next;
-		if (list ==	&ppp->channels)	{
-			i =	0;
+		if (list == &ppp->channels) {
+			i = 0;
 			break;
 		}
 	}
 
-	/* create a	fragment for each channel */
+	/* create a fragment for each channel */
 	bits = B;
-	while (len	> 0) {
+	while (len > 0) {
 		list = list->next;
-		if (list ==	&ppp->channels)	{
-			i =	0;
+		if (list == &ppp->channels) {
+			i = 0;
 			continue;
 		}
-		pch	= list_entry(list, struct channel, clist);
+		pch = list_entry(list, struct channel, clist);
 		++i;
 		if (!pch->avail)
 			continue;
 
 		/*
-		 * Skip	this channel if	it has a fragment pending already and
-		 * we haven't given	a fragment to all of the free channels.
+		 * Skip this channel if it has a fragment pending already and
+		 * we haven't given a fragment to all of the free channels.
 		 */
 		if (pch->avail == 1) {
-			if (nfree >	0)
+			if (nfree > 0)
 				continue;
 		} else {
 			pch->avail = 1;
@@ -1393,32 +1393,32 @@ static int ppp_mp_explode(struct ppp *ppp, struct sk_buff *skb)
 		/* check the channel's mtu and whether it is still attached. */
 		spin_lock_bh(&pch->downl);
 		if (pch->chan == NULL) {
-			/* can't use this channel, it's	being deregistered */
+			/* can't use this channel, it's being deregistered */
 			if (pch->speed == 0)
 				nzero--;
 			else
-				totspeed -=	pch->speed;
+				totspeed -= pch->speed;
 
 			spin_unlock_bh(&pch->downl);
 			pch->avail = 0;
 			totlen = len;
 			totfree--;
 			nfree--;
-			if (--navail ==	0)
+			if (--navail == 0)
 				break;
 			continue;
 		}
 
 		/*
 		*if the channel speed is not set divide
-		*the packet	evenly among the free channels;
+		*the packet evenly among the free channels;
 		*otherwise divide it according to the speed
 		*of the channel we are going to transmit on
 		*/
 		flen = len;
 		if (nfree > 0) {
 			if (pch->speed == 0) {
-				flen = totlen/nfree	;
+				flen = totlen/nfree;
 				if (nbigger > 0) {
 					flen++;
 					nbigger--;
@@ -1436,8 +1436,8 @@ static int ppp_mp_explode(struct ppp *ppp, struct sk_buff *skb)
 		}
 
 		/*
-		 *check	if we are on the last channel or
-		 *we exceded the lenght	of the data	to
+		 *check if we are on the last channel or
+		 *we exceded the lenght of the data to
 		 *fragment
 		 */
 		if ((nfree <= 0) || (flen > len))
@@ -1448,29 +1448,29 @@ static int ppp_mp_explode(struct ppp *ppp, struct sk_buff *skb)
 		 *above formula will be equal or less than zero.
 		 *Skip the channel in this case
 		 */
-		if (flen <=	0) {
+		if (flen <= 0) {
 			pch->avail = 2;
 			spin_unlock_bh(&pch->downl);
 			continue;
 		}
 
-		mtu	= pch->chan->mtu - hdrlen;
-		if (mtu	< 4)
-			mtu	= 4;
+		mtu = pch->chan->mtu - hdrlen;
+		if (mtu < 4)
+			mtu = 4;
 		if (flen > mtu)
 			flen = mtu;
-		if (flen ==	len)
-			bits |=	E;
-		frag = alloc_skb(flen +	hdrlen + (flen == 0), GFP_ATOMIC);
+		if (flen == len)
+			bits |= E;
+		frag = alloc_skb(flen + hdrlen + (flen == 0), GFP_ATOMIC);
 		if (!frag)
 			goto noskb;
-		q =	skb_put(frag, flen + hdrlen);
+		q = skb_put(frag, flen + hdrlen);
 
-		/* make	the	MP header */
+		/* make the MP header */
 		q[0] = PPP_MP >> 8;
 		q[1] = PPP_MP;
 		if (ppp->flags & SC_MP_XSHORTSEQ) {
-			q[2] = bits	+ ((ppp->nxseq >> 8) & 0xf);
+			q[2] = bits + ((ppp->nxseq >> 8) & 0xf);
 			q[3] = ppp->nxseq;
 		} else {
 			q[2] = bits;
@@ -1483,24 +1483,24 @@ static int ppp_mp_explode(struct ppp *ppp, struct sk_buff *skb)
 
 		/* try to send it down the channel */
 		chan = pch->chan;
-		if (!skb_queue_empty(&pch->file.xq)	||
+		if (!skb_queue_empty(&pch->file.xq) ||
 			!chan->ops->start_xmit(chan, frag))
 			skb_queue_tail(&pch->file.xq, frag);
-		pch->had_frag =	1;
+		pch->had_frag = 1;
 		p += flen;
-		len	-= flen;
+		len -= flen;
 		++ppp->nxseq;
 		bits = 0;
 		spin_unlock_bh(&pch->downl);
 	}
-	ppp->nxchan	= i;
+	ppp->nxchan = i;
 
 	return 1;
 
  noskb:
 	spin_unlock_bh(&pch->downl);
 	if (ppp->debug & 1)
-		printk(KERN_ERR	"PPP: no memory	(fragment)\n");
+		printk(KERN_ERR "PPP: no memory (fragment)\n");
 	++ppp->dev->stats.tx_errors;
 	++ppp->nxseq;
 	return 1;	/* abandon the frame */

-- 
Len Sorensen
