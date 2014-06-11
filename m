From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v3] net: add skb allocation flags to pskb_copy
Date: Wed, 11 Jun 2014 09:22:14 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1725AC13@AcuExch.aculab.com>
References: <1402477954-1267-1-git-send-email-octavian.purdila@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "christoph.paasch@uclouvain.be" <christoph.paasch@uclouvain.be>,
	"Alexander Smirnov" <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	"Simon Wunderlich" <sw@simonwunderlich.de>,
	Antonio Quartulli <antonio@meshcoding.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	"Gustavo Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"Arvid Brodin" <arvid.brodin@alten.se>,
	Patrick McHardy <kaber@trash.net>,
	"Pablo Neira Ayuso" <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	"Jon Maloy" <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	Andrew Hendry <andrew.hendry@gmail.com>,
	"Eric Dumazet" <edumazet
To: 'Octavian Purdila' <octavian.purdila@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:54226 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751015AbaFKJXG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 05:23:06 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 25541-10 for <netdev@vger.kernel.org>;
 Wed, 11 Jun 2014 10:22:55 +0100 (BST)
In-Reply-To: <1402477954-1267-1-git-send-email-octavian.purdila@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila
> There are several instances where a pskb_copy or __pskb_copy is
> immediately followed by an skb_clone. Add a new parameter to allow the
> skb to be allocated from the fclone cache and thus speed up subsequent
> skb_clone calls.
...
> @@ -2233,9 +2233,9 @@ static inline dma_addr_t skb_frag_dma_map(struct device *dev,
>  }
> 
>  static inline struct sk_buff *pskb_copy(struct sk_buff *skb,
> -					gfp_t gfp_mask)
> +					gfp_t gfp_mask, bool fclone)
>  {
> -	return __pskb_copy(skb, skb_headroom(skb), gfp_mask);
> +	return __pskb_copy(skb, skb_headroom(skb), gfp_mask, fclone);
...

Why not add:
static inline struct sk_buff *pskb_copy_for_clone(struct sk_buff *skb,
					gfp_t gfp_mask)
{
	return __pskb_copy(skb, skb_headroom(skb), gfp_mask, true);
}

So that only some of the call sites need changing.
The different function name is probably easier to grok than a Boolean
parameter.

	David
