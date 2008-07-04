From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 5/5] net/core: Allow receive on active slaves.
Date: Fri, 04 Jul 2008 08:45:52 -0400
Message-ID: <486E1B80.7060900@pobox.com>
References: <12150481222323-git-send-email-fubar@us.ibm.com> <12150481241992-git-send-email-fubar@us.ibm.com> <1215048125108-git-send-email-fubar@us.ibm.com> <12150481262025-git-send-email-fubar@us.ibm.com> <1215048127619-git-send-email-fubar@us.ibm.com> <1215048128335-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Joe Eykholt <jre@nuovasystems.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43457 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753711AbYGDMp4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2008 08:45:56 -0400
In-Reply-To: <1215048128335-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
> From: Joe Eykholt <jre@nuovasystems.com>
> 
> If a packet_type specifies an active slave to bonding and not just any
> interface, allow it to receive frames that came in on that interface.
> 
> Signed-off-by: Joe Eykholt <jre@nuovasystems.com>
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
> ---
>  net/core/dev.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index a949664..d68f662 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2104,7 +2104,8 @@ int netif_receive_skb(struct sk_buff *skb)
>  #endif
>  
>  	list_for_each_entry_rcu(ptype, &ptype_all, list) {
> -		if (ptype->dev == null_or_orig || ptype->dev == skb->dev) {
> +		if (ptype->dev == null_or_orig || ptype->dev == skb->dev ||
> +		    ptype->dev == orig_dev) {
>  			if (pt_prev)
>  				ret = deliver_skb(skb, pt_prev, orig_dev);
>  			pt_prev = ptype;
> @@ -2129,7 +2130,8 @@ ncls:
>  	list_for_each_entry_rcu(ptype,
>  			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
>  		if (ptype->type == type &&
> -		    (ptype->dev == null_or_orig || ptype->dev == skb->dev)) {
> +		    (ptype->dev == null_or_orig || ptype->dev == skb->dev ||
> +		     ptype->dev == orig_dev)) {
>  			if (pt_prev)

This needs a review&ack from David, then OK...


