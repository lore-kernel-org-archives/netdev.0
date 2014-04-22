From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3 1/3] net: ipv6: Unduplicate
 {raw,udp}v6_sendmsg code
Date: Tue, 22 Apr 2014 08:59:05 -0700
Message-ID: <1398182345.29946.51.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1398154415-24486-1-git-send-email-lorenzo@google.com>
	 <1398179656-9313-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	hannes@stressinduktion.org, davem@davemloft.net
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:57958 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757254AbaDVP7J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 11:59:09 -0400
Received: by mail-pd0-f178.google.com with SMTP id x10so5019290pdj.37
        for <netdev@vger.kernel.org>; Tue, 22 Apr 2014 08:59:09 -0700 (PDT)
In-Reply-To: <1398179656-9313-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-04-23 at 00:14 +0900, Lorenzo Colitti wrote:

> +	dst = ip6_sk_dst_lookup_flow(sk, fl6, final_p);
> +	if (IS_ERR(dst)) {
> +		fl6_sock_release(flowlabel);
> +		return PTR_ERR(dst);
> +	}
> +
> +	if (*hlimit < 0) {
> +		if (ipv6_addr_is_multicast(&fl6->daddr))
> +			*hlimit = np->mcast_hops;
> +		else
> +			*hlimit = np->hop_limit;
> +		if (*hlimit < 0)
> +			*hlimit = ip6_dst_hoplimit(dst);
> +	}
> +
> +	if (*tclass < 0)
> +		*tclass = np->tclass;
> +
> +	if (*dontfrag < 0)
> +		*dontfrag = np->dontfrag;
> +
> +	*dstp = dst;
> +	*optp = opt;
> +
> +	return 0;
> +}


Don't you leak a reference on struct ip6_flowlabel *flowlabel ?
