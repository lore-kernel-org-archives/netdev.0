From: Erik Kline <ek@google.com>
Subject: Re: [PATCH v2] net: ping: Return EAFNOSUPPORT when appropriate.
Date: Wed, 4 Mar 2015 17:58:25 +0900
Message-ID: <CAAedzxqmUUfcQh7tsqS8BZXo2Ru-wGofSWpyW4dEOBnaACig2Q@mail.gmail.com>
References: <1425387387-22874-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f47.google.com ([209.85.216.47]:64803 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751537AbbCDI6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 03:58:46 -0500
Received: by mail-qa0-f47.google.com with SMTP id v10so32396184qac.6
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 00:58:45 -0800 (PST)
In-Reply-To: <1425387387-22874-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> @@ -305,6 +308,11 @@ static int ping_check_bind_addr(struct sock *sk, struct inet_sock *isk,
>                 if (addr_len < sizeof(*addr))
>                         return -EINVAL;
>
> +               if (addr->sin_family != AF_INET &&
> +                   !(addr->sin_family == AF_UNSPEC &&
> +                     addr->sin_addr.s_addr == htonl(INADDR_ANY)))
> +                       return -EAFNOSUPPORT;
> +

Aside: I would be all in favor of deprecating this legacy "bind to \0
and gee whiz it just works (for IPv4)" kind of behaviour.  But
anyway...

Acked-by: Erik Kline <ek@google.com>
