From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v3 3/3] 6lowpan: remove excessive argument in
 pr_debug
Date: Sat, 09 Jun 2012 12:53:13 -0700
Message-ID: <1339271593.8170.10.camel@joe2Laptop>
References: <1339254789-10712-1-git-send-email-alex.bluesman.smirnov@gmail.com>
	 <1339254789-10712-4-git-send-email-alex.bluesman.smirnov@gmail.com>
	 <1339270662.8170.6.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:43500 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751080Ab2FITxO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jun 2012 15:53:14 -0400
In-Reply-To: <1339270662.8170.6.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-06-09 at 12:37 -0700, Joe Perches wrote:
> On Sat, 2012-06-09 at 19:13 +0400, Alexander Smirnov wrote:
> > Remove excessive __func__ argument in pr_debug function.
[]
> > diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
[]
> > @@ -543,7 +541,7 @@ static int lowpan_header_create(struct sk_buff *skb,
> >  			hc06_ptr += 16;
> >  		}
> >  	} else {
> > -		pr_debug("(%s): destination address is unicast: ", __func__);
> > +		pr_debug("destination address is unicast: ");
> >  		/* TODO: context lookup */
> >  		if (is_addr_link_local(&hdr->daddr)) {
> >  			pr_debug("destination address is link-local\n");
> 
> This doesn't really look correct.  Should this be newline terminated?

Instead of:
		pr_debug("destination address is unicast: ");
		/* TODO: context lookup */
		if (is_addr_link_local(&hdr->daddr)) {
			pr_debug("destination address is link-local\n");
			iphc1 |= lowpan_compress_addr_64(&hc06_ptr,
				LOWPAN_IPHC_DAM_BIT, &hdr->daddr, daddr);
		} else {
			pr_debug("using full address\n");
			memcpy(hc06_ptr, &hdr->daddr.s6_addr16[0], 16);
			hc06_ptr += 16;
		}

Perhaps something like the below is better:

		/* TODO: context lookup */
		if (is_addr_link_local(&hdr->daddr)) {
			pr_debug("destination address is unicast and link-local\n");
			iphc1 |= lowpan_compress_addr_64(&hc06_ptr,
				LOWPAN_IPHC_DAM_BIT, &hdr->daddr, daddr);
		} else {
			pr_debug("destination address is unicast: using full address\n");
			memcpy(hc06_ptr, &hdr->daddr.s6_addr16[0], 16);
			hc06_ptr += 16;
		}
