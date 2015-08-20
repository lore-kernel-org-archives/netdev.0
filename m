From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v2 2/9] geneve: Use skb mark and protocol to
 lookup route.
Date: Thu, 20 Aug 2015 18:47:27 +0200
Message-ID: <20150820164727.GA8475@pox.localdomain>
References: <1439845905-31666-1-git-send-email-pshelar@nicira.com>
 <1439845905-31666-3-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:34521 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752266AbbHTQra (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 12:47:30 -0400
Received: by wicne3 with SMTP id ne3so21248031wic.1
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 09:47:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1439845905-31666-3-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/17/15 at 02:11pm, Pravin B Shelar wrote:
> On packet transmit path geneve need to lookup route. Following
> patch improves route lookup using more parameters.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
>  drivers/net/geneve.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> index 51f7f8b..4f4d15e 100644
> --- a/drivers/net/geneve.c
> +++ b/drivers/net/geneve.c
> @@ -202,6 +202,9 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
>  	memset(&fl4, 0, sizeof(fl4));
>  	fl4.flowi4_tos = RT_TOS(tos);
>  	fl4.daddr = geneve->remote.sin_addr.s_addr;
> +	fl4.flowi4_mark = skb->mark;
> +	fl4.flowi4_proto = IPPROTO_UDP;

Looks like it's time to add a helper for this so we don't lag behind
in specifying flowi parameters in various lookup sites all the time.

Acked-by: Thomas Graf <tgraf@suug.ch>
