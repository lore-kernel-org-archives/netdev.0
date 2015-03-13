From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/3] inet_diag: factorize code in new
 inet_diag_msg_common_fill() helper
Date: Fri, 13 Mar 2015 15:48:08 -0700
Message-ID: <1426286888.11398.193.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1426277958-9772-1-git-send-email-edumazet@google.com>
	 <1426277958-9772-4-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:34914 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300AbbCMWsK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 18:48:10 -0400
Received: by ieclw3 with SMTP id lw3so130608472iec.2
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2015 15:48:09 -0700 (PDT)
In-Reply-To: <1426277958-9772-4-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-03-13 at 13:19 -0700, Eric Dumazet wrote:
> Now the three type of sockets share a common base, we can factorize
> code in inet_diag_msg_common_fill().
> 
> inet_diag_entry no longer requires saddr_storage & daddr_storage
> and the extra copies.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  net/ipv4/inet_diag.c | 149 +++++++++++++++++----------------------------------
>  1 file changed, 48 insertions(+), 101 deletions(-)
> 
> diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
> index d827fe2e3ce0..abf5e75d0a75 100644
> --- a/net/ipv4/inet_diag.c
> +++ b/net/ipv4/inet_diag.c
> @@ -44,10 +44,6 @@ struct inet_diag_entry {
>  	u16 dport;
>  	u16 family;
>  	u16 userlocks;
> -#if IS_ENABLED(CONFIG_IPV6)
> -	struct in6_addr saddr_storage;	/* for IPv4-mapped-IPv6 addresses */
> -	struct in6_addr daddr_storage;	/* for IPv4-mapped-IPv6 addresses */
> -#endif
>  };
>  
>  static DEFINE_MUTEX(inet_diag_table_mutex);
> @@ -70,6 +66,31 @@ static void inet_diag_unlock_handler(const struct inet_diag_handler *handler)
>  	mutex_unlock(&inet_diag_table_mutex);
>  }
>  
> +static void inet_diag_msg_common_fill(struct inet_diag_msg *r,
> +				      const struct sock *sk)

Arg this const qualifier needs to be removed

Will send a v2, sorry.
