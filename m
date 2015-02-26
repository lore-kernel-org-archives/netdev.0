From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 6/7] net: add common accessor for setting
 dropcount on packets
Date: Wed, 25 Feb 2015 20:43:04 -0800
Message-ID: <1424925784.5565.147.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1424916612-744-1-git-send-email-eyal.birger@gmail.com>
	 <1424916612-744-7-git-send-email-eyal.birger@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, willemb@google.com, edumazet@google.com,
	shmulik.ladkani@gmail.com, marcel@holtmann.org,
	netdev@vger.kernel.org
To: Eyal Birger <eyal.birger@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:43823 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751963AbbBZEnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 23:43:06 -0500
Received: by iebtr6 with SMTP id tr6so11016978ieb.10
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 20:43:05 -0800 (PST)
In-Reply-To: <1424916612-744-7-git-send-email-eyal.birger@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-02-26 at 04:10 +0200, Eyal Birger wrote:
> As part of an effort to move skb->dropcount to skb->cb[], use
> a common function in order to set dropcount in struct sk_buff.
> 
> Signed-off-by: Eyal Birger <eyal.birger@gmail.com>
> ---
>  include/net/sock.h     | 5 +++++
>  net/core/sock.c        | 2 +-
>  net/packet/af_packet.c | 2 +-
>  3 files changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/include/net/sock.h b/include/net/sock.h
> index a2502d2..d462f5e 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -2081,6 +2081,11 @@ static inline int sock_intr_errno(long timeo)
>  #define sock_skb_cb_check_size(size) \
>  	BUILD_BUG_ON((size) > FIELD_SIZEOF(struct sk_buff, cb))
>  
> +static inline void sock_skb_set_dropcount(struct sock *sk, struct sk_buff *skb)

const struct sock *sk


> +{
> +	skb->dropcount = atomic_read(&sk->sk_drops);
> +}
