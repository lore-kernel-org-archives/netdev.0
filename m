From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/5 net-next] inet: replace ->bind_conflict with
 ->rcv_saddr_equal
Date: Wed, 21 Dec 2016 16:23:06 +0100
Message-ID: <1482333786.2260.10.camel@stressinduktion.org>
References: <1482264424-15439-1-git-send-email-jbacik@fb.com>
         <1482264424-15439-2-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
To: Josef Bacik <jbacik@fb.com>, davem@davemloft.net,
        kraigatgoog@gmail.com, eric.dumazet@gmail.com, tom@herbertland.com,
        netdev@vger.kernel.org, kernel-team@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:52187 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1758883AbcLUPXL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 10:23:11 -0500
In-Reply-To: <1482264424-15439-2-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-12-20 at 15:07 -0500, Josef Bacik wrote:
> --- a/net/dccp/ipv6.c
> +++ b/net/dccp/ipv6.c
> @@ -926,7 +926,7 @@ static const struct inet_connection_sock_af_ops dccp_ipv6_af_ops = {
>  	.getsockopt	   = ipv6_getsockopt,
>  	.addr2sockaddr	   = inet6_csk_addr2sockaddr,
>  	.sockaddr_len	   = sizeof(struct sockaddr_in6),
> -	.bind_conflict	   = inet6_csk_bind_conflict,
> +	.rcv_saddr_equal   = ipv6_rcv_saddr_equal,
>  #ifdef CONFIG_COMPAT
>  	.compat_setsockopt = compat_ipv6_setsockopt,
>  	.compat_getsockopt = compat_ipv6_getsockopt,
> 

Btw, small nit, you forgot the corresponding changes in
dccp_ipv6_mapped, thus causing this compiler error:

net/dccp/ipv6.c:961:2: error: unknown field ‘bind_conflict’ specified in initializer
  .bind_conflict    = inet6_csk_bind_conflict,
  ^
net/dccp/ipv6.c:961:22: error: ‘inet6_csk_bind_conflict’ undeclared here (not in a function)
  .bind_conflict    = inet6_csk_bind_conflict,
                      ^~~~~~~~~~~~~~~~~~~~~~~
scripts/Makefile.build:293: recipe for target 'net/dccp/ipv6.o' failed

Bye,
Hannes
