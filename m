From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] ipv4: hash net ptr into fragmentation
 bucket selection
Date: Wed, 25 Mar 2015 07:45:00 -0700
Message-ID: <1427294700.25985.114.camel@edumazet-glaptop2.roam.corp.google.com>
References: <8d98fd0e002553538fb43e5fcafff38f3d65153f.1427291651.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Flavio Leitner <fbl@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:33729 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932770AbbCYOpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 10:45:03 -0400
Received: by iecvj10 with SMTP id vj10so23777095iec.0
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 07:45:02 -0700 (PDT)
In-Reply-To: <8d98fd0e002553538fb43e5fcafff38f3d65153f.1427291651.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-03-25 at 15:00 +0100, Hannes Frederic Sowa wrote:
> As namespaces are sometimes used with overlapping ip address ranges,
> we should also use the namespace as input to the hash to select the ip
> fragmentation counter bucket.
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Flavio Leitner <fbl@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  drivers/net/ppp/pptp.c          | 2 +-
>  net/netfilter/ipvs/ip_vs_xmit.c | 5 +++--
>  2 files changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
> index 1dc628f..e3bfbd4d 100644
> --- a/drivers/net/ppp/pptp.c
> +++ b/drivers/net/ppp/pptp.c
> @@ -281,7 +281,7 @@ static int pptp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
>  	nf_reset(skb);
>  
>  	skb->ip_summed = CHECKSUM_NONE;
> -	ip_select_ident(skb, NULL);
> +	ip_select_ident(sock_net(sk), skb, NULL);
>  	ip_send_check(iph);
>  

I do not see how this would compile, without corresponding change in
ip_select_ident() ?

Or maybe I should drink this coffee ;)

Really, Redhat should tell truth to its customers : frags are bad
