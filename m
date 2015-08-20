From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v2 4/9] geneve: Make dst-port configurable.
Date: Thu, 20 Aug 2015 18:58:05 +0200
Message-ID: <20150820165805.GD8475@pox.localdomain>
References: <1439845905-31666-1-git-send-email-pshelar@nicira.com>
 <1439845905-31666-5-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:37744 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308AbbHTQ6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 12:58:08 -0400
Received: by widdq5 with SMTP id dq5so11711581wid.0
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 09:58:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1439845905-31666-5-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/17/15 at 02:11pm, Pravin B Shelar wrote:
> @@ -403,6 +416,7 @@ static size_t geneve_get_size(const struct net_device *dev)
>  		nla_total_size(sizeof(struct in_addr)) + /* IFLA_GENEVE_REMOTE */
>  		nla_total_size(sizeof(__u8)) +  /* IFLA_GENEVE_TTL */
>  		nla_total_size(sizeof(__u8)) +  /* IFLA_GENEVE_TOS */
> +		nla_total_size(sizeof(__u16)) +  /* IFLA_GENEVE_PORT */
>  		0;
>  }
>  
> @@ -423,6 +437,9 @@ static int geneve_fill_info(struct sk_buff *skb, const struct net_device *dev)
>  	    nla_put_u8(skb, IFLA_GENEVE_TOS, geneve->tos))
>  		goto nla_put_failure;
>  
> +	if (nla_put_u32(skb, IFLA_GENEVE_PORT, ntohs(geneve->dst_port)))
> +		goto nla_put_failure;

nla_put_u16?
