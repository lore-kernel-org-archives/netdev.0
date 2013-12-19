From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 3/9] net: phy: dp83640: fix checkpath error
Date: Thu, 19 Dec 2013 14:31:02 -0800
Message-ID: <1387492262.2353.26.camel@joe-AO722>
References: <1387345093-14168-1-git-send-email-f.fainelli@gmail.com>
	 <1387345093-14168-4-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0130.hostedemail.com ([216.40.44.130]:59842 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754699Ab3LSWbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 17:31:04 -0500
In-Reply-To: <1387345093-14168-4-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-17 at 21:38 -0800, Florian Fainelli wrote:
> diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
[]
> @@ -851,8 +851,8 @@ static int match(struct sk_buff *skb, unsigned int type, struct rxts *rxts)
>  
>  	seqid = (u16 *)(data + offset + OFF_PTP_SEQUENCE_ID);
>  
> -	return (rxts->msgtype == (*msgtype & 0xf) &&
> -		rxts->seqid   == ntohs(*seqid));
> +	return rxts->msgtype == (*msgtype & 0xf) &&
> +		rxts->seqid   == ntohs(*seqid);

I think this isn't an improvement.

Maybe:

	return rxts->msgtype == (*msgtype & 0xf) &&
	       rxts->seqid == ntohs(*seqid);

or

	return (rxts->msgtype == (*msgtype & 0xf)) &&
	       (rxts->seqid == ntohs(*seqid));
