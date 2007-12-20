From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] [IPROUTE]: A workaround to make larger rto_min printed
	correctly
Date: Thu, 20 Dec 2007 10:12:30 +0100
Message-ID: <20071220091230.GB1924@ff.dom.local>
References: <d72b7ace0712191931w37f02645u8d5eb5eef9c1fba4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Satoru SATOH <satoru.satoh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.240]:21703 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754575AbXLTJHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 04:07:12 -0500
Received: by an-out-0708.google.com with SMTP id d31so816322and.103
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2007 01:07:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <d72b7ace0712191931w37f02645u8d5eb5eef9c1fba4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20-12-2007 04:31, Satoru SATOH wrote:
> "ip route show" does not print correct value when larger rto_min is
> set (e.g. 3sec).
> 
> This problem is because of overflow in print_route() and
> the patch below is a workaround fix for that.
> 
...
> --- a/ip/iproute.c
> +++ b/ip/iproute.c
> @@ -510,16 +510,16 @@ int print_route(const struct sockaddr_nl *who,
> struct nlmsghdr *n, void *arg)
>                                 fprintf(fp, " %u",
> *(unsigned*)RTA_DATA(mxrta[i]));
>                         else {
>                                 unsigned val = *(unsigned*)RTA_DATA(mxrta[i]);
> +                               unsigned hz1 = hz / 1000;
...
> +                               if (val >= hz1)
> +                                       fprintf(fp, " %ums", val/hz1);
...

Probably I miss something or my iproute sources are too old, but:
does this work with hz < 1000?

Regards,
Jarek P.
