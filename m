From: Joe Perches <joe@perches.com>
Subject: Re: [RFC 3/3] networking: make skb_push & __skb_push return void
 pointers
Date: Fri, 16 Jun 2017 02:19:18 -0700
Message-ID: <1497604758.10546.3.camel@perches.com>
References: <20170615221217.16510-1-johannes@sipsolutions.net>
         <20170615221217.16510-4-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0135.hostedemail.com ([216.40.44.135]:39795 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753237AbdFPJTW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 05:19:22 -0400
In-Reply-To: <20170615221217.16510-4-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-06-16 at 00:12 +0200, Johannes Berg wrote:
> From: Johannes Berg <johannes.berg@intel.com>
[]
> diff --git a/drivers/nfc/pn533/pn533.c b/drivers/nfc/pn533/pn533.c
[]
> @@ -2090,10 +2090,10 @@ static int pn533_fill_fragment_skbs(struct pn533 *dev, struct sk_buff *skb)
>  
>  			/* MI + TG */
>  			if (frag_size  == PN533_CMD_DATAFRAME_MAXLEN)
> -				*skb_push(frag, sizeof(u8)) =
> -							(PN533_CMD_MI_MASK | 1);
> -			else
> -				*skb_push(frag, sizeof(u8)) =  1; /* TG */
> +				*(u8 *)skb_push(frag, sizeof(u8)) =
> +									(PN533_CMD_MI_MASK | 1);
> +				else
> +					*(u8 *)skb_push(frag, sizeof(u8)) =  1; /* TG */

Can you check all the if/else uses.
This one is not formatted correctly.
I didn't look at any others.
