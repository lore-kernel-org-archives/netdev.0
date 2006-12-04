From: Patrick McHardy <kaber@trash.net>
Subject: Re: [XFRM] Optimize SA dumping
Date: Mon, 04 Dec 2006 13:36:27 +0100
Message-ID: <4574164B.1000505@trash.net>
References: <1165163610.3517.96.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:30123 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S936265AbWLDMdU
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 07:33:20 -0500
To: hadi@cyberus.ca
In-Reply-To: <1165163610.3517.96.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
>  	for (i = 0; i <= xfrm_state_hmask; i++) {
>  		hlist_for_each_entry(x, entry, xfrm_state_bydst+i, bydst) {
> +			if (count && send_x != last_x) {
> +				err = func(send_x, count, data);
> +				if (err)
> +					goto out;
> +				send_x = NULL;
> +			}
>  			if (!xfrm_id_proto_match(x->id.proto, proto))
>  				continue;

After you sent send_x and set it to NULL, it will be different from
last_x (since that is != NULL) and the NULL pointer will be given
to func() when continuing here.

> -			err = func(x, --count, data);
> -			if (err)
> -				goto out;
> +
> +			if (!count) {
> +				last_x = send_x = x;
> +			} else {
> +				send_x = last_x;
> +				last_x = x;
> +			}
> +			count++;
>  		}
>  	}




