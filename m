From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: act_mirred: Fix bogus header when redirecting from VLAN
Date: Thu, 16 Apr 2015 18:34:02 -0700
Message-ID: <20150417013401.GA4335@Alexeis-MacBook-Pro.local>
References: <20150417010216.GA22415@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jamal <hadi@cyberus.ca>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33985 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752062AbbDQBeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 21:34:04 -0400
Received: by pacyx8 with SMTP id yx8so108304326pac.1
        for <netdev@vger.kernel.org>; Thu, 16 Apr 2015 18:34:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150417010216.GA22415@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 17, 2015 at 09:02:16AM +0800, Herbert Xu wrote:
> @@ -105,7 +105,7 @@ static void ri_tasklet(unsigned long dev)
>  		if (from & AT_EGRESS) {
>  			dev_queue_xmit(skb);
>  		} else if (from & AT_INGRESS) {
> -			skb_pull(skb, skb->dev->hard_header_len);
> +			skb_pull(skb, _dev->hard_header_len);
...
>  	if (!(at & AT_EGRESS)) {
>  		if (m->tcfm_ok_push)
> -			skb_push(skb2, skb2->dev->hard_header_len);
> +			skb_push(skb2, dev->hard_header_len);

seems the cleaner fix will be to push skb->mac_len instead?
