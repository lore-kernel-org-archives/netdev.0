From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: linux-next: BUG: unable to handle kernel NULL pointer
 dereference in __sk_mem_raise_allocated()
Date: Mon, 14 Nov 2016 15:49:15 -0800
Message-ID: <1479167355.8455.93.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CANaxB-yCk8hhP68L4Q2nFOJht8sqgXGGQO2AftpHs0u1xyGG5A@mail.gmail.com>
         <1479166501.8455.91.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Paolo Abeni <pabeni@redhat.com>
To: Andrei Vagin <avagin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35855 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S940854AbcKNXtR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 18:49:17 -0500
Received: by mail-pg0-f65.google.com with SMTP id x23so10112969pgx.3
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 15:49:17 -0800 (PST)
In-Reply-To: <1479166501.8455.91.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-11-14 at 15:35 -0800, Eric Dumazet wrote:

> 
> Thanks for the report.
> 
> I guess following patch would be needed ?
> 
> diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
> index af817158d830c0da080935ba29e012dffbb89112..12604c0371c451efcc9aad278bb86be9ac4bb813 100644
> --- a/net/ipv4/udplite.c
> +++ b/net/ipv4/udplite.c
> @@ -54,6 +54,7 @@ struct proto 	udplite_prot = {
>  	.hash		   = udp_lib_hash,
>  	.unhash		   = udp_lib_unhash,
>  	.get_port	   = udp_v4_get_port,
> +	.memory_allocated  = &udp_memory_allocated,
>  	.obj_size	   = sizeof(struct udp_sock),
>  	.h.udp_table	   = &udplite_table,
>  #ifdef CONFIG_COMPAT
> diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
> index 47d0d2b87106558fece3496479198005c55b99e7..946025c888cc9519fb3523edbbe8afbb18273326 100644
> --- a/net/ipv6/udplite.c
> +++ b/net/ipv6/udplite.c
> @@ -49,6 +49,7 @@ struct proto udplitev6_prot = {
>  	.hash		   = udp_lib_hash,
>  	.unhash		   = udp_lib_unhash,
>  	.get_port	   = udp_v6_get_port,
> +	.memory_allocated  = &udp_memory_allocated,
>  	.obj_size	   = sizeof(struct udp6_sock),
>  	.h.udp_table	   = &udplite_table,
>  #ifdef CONFIG_COMPAT
> 

.sysctl_mem also needs to be set.
