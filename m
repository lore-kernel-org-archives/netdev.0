From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next 04/13] fou: Split out {fou,gue}_build_header
Date: Thu, 12 May 2016 21:55:22 +0300
Message-ID: <20160512215522.1bc7ec75@halley>
References: <1462985253-2380625-1-git-send-email-tom@herbertland.com>
	<1462985253-2380625-5-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33842 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752298AbcELSze (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 14:55:34 -0400
Received: by mail-wm0-f68.google.com with SMTP id n129so17542086wmn.1
        for <netdev@vger.kernel.org>; Thu, 12 May 2016 11:55:34 -0700 (PDT)
In-Reply-To: <1462985253-2380625-5-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

On Wed, 11 May 2016 09:47:24 -0700 Tom Herbert <tom@herbertland.com> wrote:
>  
> -int fou_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
> -		     u8 *protocol, struct flowi4 *fl4);
> -int gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
> -		     u8 *protocol, struct flowi4 *fl4);
> +int __fou_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
> +		       u8 *protocol, __be16 *sport, int type);
> +int __gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
> +		       u8 *protocol, __be16 *sport, int type);

[snip]

> +EXPORT_SYMBOL(__fou_build_header);
> +
>  int fou_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
>  		     u8 *protocol, struct flowi4 *fl4)

Assuming 'fou_build_header' is no longer part of the interface, why
not kill the existing EXPORT_SYMBOL(fou_build_header) and make it
static?

Same for 'gue_build_header'.

Regards,
Shmulik
