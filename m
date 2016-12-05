From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ping: check minimum size on ICMP header length
Date: Mon, 05 Dec 2016 13:19:32 -0500 (EST)
Message-ID: <20161205.131932.1911368739049813377.davem@davemloft.net>
References: <20161203005853.GA117599@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchong@google.com, i@flanker017.me,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, linux-kernel@vger.kernel.org
To: keescook@chromium.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47350 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751485AbcLESTf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 13:19:35 -0500
In-Reply-To: <20161203005853.GA117599@beast>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kees Cook <keescook@chromium.org>
Date: Fri, 2 Dec 2016 16:58:53 -0800

> diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
> index 205e2000d395..8257be3f032c 100644
> --- a/net/ipv4/ping.c
> +++ b/net/ipv4/ping.c
> @@ -654,7 +654,7 @@ int ping_common_sendmsg(int family, struct msghdr *msg, size_t len,
>  			void *user_icmph, size_t icmph_len) {
>  	u8 type, code;
>  
> -	if (len > 0xFFFF)
> +	if (len > 0xFFFF || len < icmph_len)
>  		return -EMSGSIZE;

As suggested by Lorenzo, please use -EINVAL here.

Thanks.
