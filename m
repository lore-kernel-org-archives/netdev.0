From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] af-packet: fix oops when socket is not present
Date: Tue, 06 Nov 2012 03:34:02 -0800
Message-ID: <1352201642.3140.880.camel@edumazet-glaptop>
References: <1352197481-16782-1-git-send-email-eric@regit.org>
	 <1352197481-16782-2-git-send-email-eric@regit.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, stable@vger.kernel.org
To: Eric Leblond <eric@regit.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:43405 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751911Ab2KFLeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 06:34:07 -0500
In-Reply-To: <1352197481-16782-2-git-send-email-eric@regit.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-11-06 at 11:24 +0100, Eric Leblond wrote:
> When skb->sk is NULL and when packet fanout is used, there is a
> crash in match_fanout_group where skb->sk is accessed.
> This patch fixes the issue by returning false as soon as the
> socket is NULL: this correspond to the wanted behavior because
> the kernel as to resend the skb to all the listening socket in
> this case.
> 
> Signed-off-by: Eric Leblond <eric@regit.org>
> ---
>  net/core/dev.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index b4978e2..c7b5293 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1666,7 +1666,7 @@ static inline int deliver_skb(struct sk_buff *skb,
>  
>  static inline bool skb_loop_sk(struct packet_type *ptype, struct sk_buff *skb)
>  {
> -	if (ptype->af_packet_priv == NULL)
> +	if ((ptype->af_packet_priv == NULL) || (skb->sk == NULL))

Why adding these parentheses  ?

if (!ptype->af_packet_priv || !skb->sk)


>  		return false;
>  
>  	if (ptype->id_match)

Your patch is technically correct, but misses extra information to ease
stable team work.

Your previous mail with this useful information wont be part of the
patch.

Please add this information in the changelog ?

Thanks
