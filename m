From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next RFC] tbf: handle gso skbs properly
Date: Fri, 15 Feb 2013 07:30:38 -0800
Message-ID: <1360942238.19353.6.camel@edumazet-glaptop>
References: <1360932297-6698-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	jhs@mojatatu.com, kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:39831 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933003Ab3BOPam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 10:30:42 -0500
Received: by mail-pb0-f53.google.com with SMTP id un1so646227pbc.26
        for <netdev@vger.kernel.org>; Fri, 15 Feb 2013 07:30:41 -0800 (PST)
In-Reply-To: <1360932297-6698-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-02-15 at 13:44 +0100, Jiri Pirko wrote:

> +	segs = skb_gso_segment(skb, 0);

Try to find out how to avoid a full copy, if the device is SG capable.

maybe using 
	segs = skb_gso_segment(skb,
			netif_skb_features(skb) & ~NETIF_F_GSO_MASK);

Or something like that...

> +	if (IS_ERR(segs) || !segs)
> +		return false;
> +	__skb_unlink(skb, &qdisc->q);
> +	kfree_skb(skb);

consume_skb() would be nice here.
