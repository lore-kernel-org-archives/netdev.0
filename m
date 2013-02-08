From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH RFC v2 1/2] net/802: Implement Multiple Registration
 Protocol (MRP)
Date: Fri, 8 Feb 2013 09:37:56 +0100
Message-ID: <20130208083750.GA6802@macbook.localnet>
References: <1360295457-5245-1-git-send-email-david.ward@ll.mit.edu>
 <1360295457-5245-2-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: David Ward <david.ward@ll.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64792 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758129Ab3BHIiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 03:38:03 -0500
Content-Disposition: inline
In-Reply-To: <1360295457-5245-2-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 07, 2013 at 10:50:55PM -0500, David Ward wrote:
> Initial implementation of the Multiple Registration Protocol (MRP)
> from IEEE 802.1Q-2011, based on the existing implementation of the
> Generic Attribute Registration Protocol (GARP).
> 
> Signed-off-by: David Ward <david.ward@ll.mit.edu>

> +enum mrp_vecattr_event {
> +	MRP_NEW,
> +	MRP_JOIN_IN,
> +	MRP_IN,
> +	MRP_JOIN_MT,
> +	MRP_MT,
> +	MRP_LV,
> +};

> +static int mrp_pdu_append_event(struct mrp_applicant *app,
> +				const struct mrp_attr *attr,
> +				enum mrp_vecattr_event event)
> +{
...
> +	switch (pos) {
> +	case 0:
> +		*events = event * 36;
> +		break;
> +	case 1:
> +		*events += event * 6;
> +		break;
> +	case 2:
> +		*events += event;
> +		break;
> +	default:
> +		WARN_ON(1);
> +	}

Could you define a MRT_VAEVENT_MAX or something and use that instead of the
magic values? Took me a bit to figure out their meaning.

> +static int mrp_pdu_parse_vecattr(struct mrp_applicant *app,
> +				 struct sk_buff *skb, int *offset)
> +{
...
> +	while (valen > 0) {
> +		if (skb_copy_bits(skb, *offset, &vaevents,
> +				  sizeof(vaevents)) < 0)
> +			return -1;
> +		*offset += sizeof(vaevents);
> +
> +		/* Extract and process the first event. */
> +		vaevent = vaevents / 36;
> +		if (vaevent >= 6) {

Same here.

Other than that:

Acked-by: Patrick McHardy <kaber@trash.net>

for all patches.
