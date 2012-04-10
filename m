From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH] tcp: restore correct limit
Date: Tue, 10 Apr 2012 12:14:15 +0200
Message-ID: <4F8407F7.8070703@monstr.eu>
References: <4F83EB0E.4020104@monstr.eu>  <1334046444.3126.12.camel@edumazet-glaptop>  <1334046746.3126.13.camel@edumazet-glaptop>  <4F83F166.4010208@monstr.eu>  <1334047544.3126.14.camel@edumazet-glaptop>  <4F83F959.3070302@monstr.eu>  <1334049896.3126.23.camel@edumazet-glaptop>  <4F83FD7A.5010602@monstr.eu>  <1334050698.3126.30.camel@edumazet-glaptop> <1334052194.3126.66.camel@edumazet-glaptop>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	John Williams <john.williams@petalogix.com>,
	David Miller <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>,
	Glauber Costa <glommer@parallels.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:39410 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753734Ab2DJKOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 06:14:21 -0400
Received: by eaaq12 with SMTP id q12so1248305eaa.19
        for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 03:14:20 -0700 (PDT)
In-Reply-To: <1334052194.3126.66.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/10/2012 12:03 PM, Eric Dumazet wrote:
> Commit c43b874d5d714f (tcp: properly initialize tcp memory limits)
> added a regression on machines with low amount of memory, since sockets
> cant use 1/128 of memory but 1/1024
>
> Fix this to match comment and previous behavior.
>
> Signed-off-by: Eric Dumazet<eric.dumazet@gmail.com>
> Cc: Jason Wang<jasowang@redhat.com>
> Cc: Glauber Costa<glommer@parallels.com>
> ---
>   net/ipv4/tcp.c |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 5d54ed3..67d726e 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -3302,7 +3302,7 @@ void __init tcp_init(void)
>
>   	tcp_init_mem(&init_net);
>   	/* Set per-socket limits to no more than 1/128 the pressure threshold */
> -	limit = nr_free_buffer_pages()<<  (PAGE_SHIFT - 10);
> +	limit = nr_free_buffer_pages()<<  (PAGE_SHIFT - 7);
>   	limit = max(limit, 128UL);
>   	max_share = min(4UL*1024*1024, limit);
>

hw design with csum is also much better.
Tested-by: Michal Simek <monstr@monstr.eu>

Thanks for help,
Michal





-- 
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/fdt/
Microblaze U-BOOT custodian
