From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 3/7] netfilter: synproxy: correct wscale option passing
Date: Fri, 22 Nov 2013 21:19:10 +0400
Message-ID: <528F920E.1000809@cogentembedded.com>
References: <1385024728-4057-1-git-send-email-pablo@netfilter.org> <1385024728-4057-4-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:43406 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755938Ab3KVRTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Nov 2013 12:19:15 -0500
Received: by mail-la0-f46.google.com with SMTP id eh20so1176960lab.5
        for <netdev@vger.kernel.org>; Fri, 22 Nov 2013 09:19:14 -0800 (PST)
In-Reply-To: <1385024728-4057-4-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 21-11-2013 13:05, Pablo Neira Ayuso wrote:

> From: Martin Topholm <mph@one.com>

> Timestamp are used to store additional syncookie parameters such as sack,
> ecn, and wscale. The wscale value we need to encode is the client's
> wscale, since we can't recover that later in the session. Next overwrite
> the wscale option so the later synproxy_send_client_synack will send
> the backend's wscale to the client.

> Signed-off-by: Martin Topholm <mph@one.com>
> Reviewed-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> ---
>   net/netfilter/nf_synproxy_core.c |    7 ++++---
>   1 file changed, 4 insertions(+), 3 deletions(-)

> diff --git a/net/netfilter/nf_synproxy_core.c b/net/netfilter/nf_synproxy_core.c
> index cdf4567..9858e3e 100644
> --- a/net/netfilter/nf_synproxy_core.c
> +++ b/net/netfilter/nf_synproxy_core.c
> @@ -151,9 +151,10 @@ void synproxy_init_timestamp_cookie(const struct xt_synproxy_info *info,
>   	opts->tsecr = opts->tsval;
>   	opts->tsval = tcp_time_stamp & ~0x3f;
>
> -	if (opts->options & XT_SYNPROXY_OPT_WSCALE)
> -		opts->tsval |= info->wscale;
> -	else
> +	if (opts->options & XT_SYNPROXY_OPT_WSCALE) {
> +		opts->tsval |= opts->wscale;
> +		opts->wscale = info->wscale;
> +	} else
>   		opts->tsval |= 0xf;

    According to Documentation/CodingStyle, both arms of *if* statement should 
have {} if one arm has it.

WBR, Sergei
