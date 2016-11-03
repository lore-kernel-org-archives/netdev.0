From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCH net] ipv6: dccp: add missing bind_conflict to
 dccp_ipv6_mapped
Date: Thu, 3 Nov 2016 10:22:19 -0600
Message-ID: <20161103162219.GD5852@kernel.org>
References: <CAAeHK+y8AEQ7dM6GQa5fezgaQK+arqAfRjyVafq-K0+nqgUvGg@mail.gmail.com>
 <CANn89i+YLvnFZFQTQyUA_jxYtZ1RE1NCCb3F4gqdia+w8wuK8A@mail.gmail.com>
 <1478188786.7065.453.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Andrey Konovalov <andreyknvl@google.com>,
        netdev <netdev@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>,
        Gerrit Renker <gerrit@erg.abdn.ac.uk>, dccp@vger.kernel.org,
        Arnaldo Carvalho de Melo <acme@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:46906 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758559AbcKCQW1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Nov 2016 12:22:27 -0400
Content-Disposition: inline
In-Reply-To: <1478188786.7065.453.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Thu, Nov 03, 2016 at 08:59:46AM -0700, Eric Dumazet escreveu:
> From: Eric Dumazet <edumazet@google.com>
> 
> While fuzzing kernel with syzkaller, Andrey reported a nasty crash
> in inet6_bind() caused by DCCP lacking a required method.

Ouch, thanks, forgot the mapped case :-)

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

- Arnaldo
 
> Fixes: ab1e0a13d7029 ("[SOCK] proto: Add hashinfo member to struct proto")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Tested-by: Andrey Konovalov <andreyknvl@google.com>
> Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
> ---
>  net/dccp/ipv6.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
> index 3828f94b234c..95353bdbfa7b 100644
> --- a/net/dccp/ipv6.c
> +++ b/net/dccp/ipv6.c
> @@ -956,6 +956,7 @@ static const struct inet_connection_sock_af_ops
> dccp_ipv6_mapped = {
>  	.getsockopt	   = ipv6_getsockopt,
>  	.addr2sockaddr	   = inet6_csk_addr2sockaddr,
>  	.sockaddr_len	   = sizeof(struct sockaddr_in6),
> +	.bind_conflict	   = inet6_csk_bind_conflict,
>  #ifdef CONFIG_COMPAT
>  	.compat_setsockopt = compat_ipv6_setsockopt,
>  	.compat_getsockopt = compat_ipv6_getsockopt,
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
