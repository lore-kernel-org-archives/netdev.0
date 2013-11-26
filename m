From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 01/17] net: Add utility function to clear rxhash
Date: Tue, 26 Nov 2013 10:01:54 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7446@saturn3.aculab.com>
References: <alpine.DEB.2.02.1311252141350.23058@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: "Tom Herbert" <therbert@google.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:48279 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752822Ab3KZKDh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 05:03:37 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 21505-07 for <netdev@vger.kernel.org>;
 Tue, 26 Nov 2013 10:03:33 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <alpine.DEB.2.02.1311252141350.23058@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Tom Herbert
> 
> In several places 'skb->rxhash = 0' is being done to clear the
> rxhash value in an skb.  This does not clear l4_rxhash which could
> still be set so that the rxhash wouldn't be recalculated on subsequent
> call to skb_get_rxhash.  This patch adds an explict function to clear
> all the rxhash related information in the skb properly.
> 
...
> 
> +static inline void skb_clear_rxhash(struct sk_buff *skb)
> +{
> +	skb->rxhash = 0;
> +	skb->l4_rxhash = 0;
> +}

Wouldn't it be better to also change the names of the structure members.
Then you'd be sure to find all the uses.

And in patch 2/17 ...

+enum rxhash_types {

Add RXHASH_TYPE_UNSET

+	RXHASH_TYPE_NONE,	/* Undefined type */
+	RXHASH_TYPE_L2,		/* Uses L2 information (addresses) */
+	RXHASH_TYPE_L3,		/* Uses L3 information */
+	RXHASH_TYPE_L4,		/* Uses L4 information (ports) */
+};
+
+static inline void
+skb_set_rxhash(struct sk_buff *skb, __u32 hash, enum rxhash_types type)
+{
+	skb->l4_rxhash = (type == RXHASH_TYPE_L4);

Save the actual type.

+	skb->rxhash = hash;
+}

	David
