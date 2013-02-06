From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v2] net: adjust skb_gso_segment() for calling in rx path
Date: Wed, 6 Feb 2013 09:23:49 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7138@saturn3.aculab.com>
References: <1360118198-25440-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Jesse Gross" <jesse@nicira.com>,
	"David S. Miller" <davem@davemloft.net>
To: "Cong Wang" <amwang@redhat.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:57176 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751866Ab3BFJYo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 04:24:44 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 19177-04 for <netdev@vger.kernel.org>;
 Wed,  6 Feb 2013 09:24:43 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1360118198-25440-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +/* openvswitch calls this on rx path, so we need a different check.
> + */
> +static inline bool skb_needs_check(struct sk_buff *skb, bool tx_path)
> +{
> +	if (tx_path)
> +		return skb->ip_summed != CHECKSUM_PARTIAL;
> +	else
> +		return skb->ip_summed == CHECKSUM_NONE;
> +}
> +

That code wants a lot of unlikely() added.

It seems wrong to be adding code a very common path for one
obscure caller.

Perhaps the caller should be modifying the ip_summed field
(etc) to match the values expected for a tx skb.

	David
