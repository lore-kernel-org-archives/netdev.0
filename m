From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V2 net-next] LISP: Locator/Identifier Separation Protocol
Date: Thu, 05 Jun 2014 16:26:40 -0700
Message-ID: <1402010800.3645.279.camel@edumazet-glaptop2.roam.corp.google.com>
References: <4D3092DF-BB04-4C50-88B9-EBBA349C7B17@logicalelegance.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"Vina Ermagan (vermagan)" <vermagan@cisco.com>,
	"Lorand Jakab -X (lojakab - M SQUARED CONSULTING INC. at Cisco)"
	<lojakab@cisco.com>
To: Christopher White <chris@logicalelegance.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:34324 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752527AbaFEX0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 19:26:41 -0400
Received: by mail-pb0-f43.google.com with SMTP id up15so1790131pbc.2
        for <netdev@vger.kernel.org>; Thu, 05 Jun 2014 16:26:41 -0700 (PDT)
In-Reply-To: <4D3092DF-BB04-4C50-88B9-EBBA349C7B17@logicalelegance.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-06-05 at 14:14 -0700, Christopher White wrote:
> This is a static tunnel implementation of LISP as described in RFC 6830:
>   http://tools.ietf.org/html/rfc6830
> 

> +static void lisp_sock_put(struct sk_buff *skb)
> +{
> +	sock_put(skb->sk);
> +}
> +
> +/* On transmit, associate with the tunnel socket */
> +static void lisp_set_owner(struct sock *sk, struct sk_buff *skb)
> +{
> +	skb_orphan(skb);
> +	sock_hold(sk);
> +	skb->sk = sk;
> +	skb->destructor = lisp_sock_put;
> +}
> +

Please do not do that. 

Read commit 8f646c922d55047ecd6c65ada49ead88ed0db61e
("vxlan: keep original skb ownership")
for details.
