From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 3/4] net: dsa: Refactor transmit path
Date: Thu, 30 Jul 2015 12:40:36 -0700
Message-ID: <55BA7DB4.9060705@gmail.com>
References: <1438284939-2750-1-git-send-email-f.fainelli@gmail.com> <1438284939-2750-4-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr,
	Chris.Packham@alliedtelesis.co.nz, alexander.h.duyck@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:36208 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751235AbbG3Tmk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 15:42:40 -0400
Received: by pdjr16 with SMTP id r16so29935225pdj.3
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 12:42:39 -0700 (PDT)
In-Reply-To: <1438284939-2750-4-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/07/15 12:35, Florian Fainelli wrote:
> All tagging protocols do the same thing: increment device statistics,
> make room for the tag to be inserted, create the tag, invoke the parent
> network device transmit function.
> 
> In order to prepare for adding netpoll support, which requires the tag
> creation, but not using the parent network device transmit function, do
> some little refactoring which eliminates duplication between the 4
> tagging protocols supported.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
[snip]

>  	/*
>  	 * We have to make sure that the trailer ends up as the very
>  	 * last 4 bytes of the packet.  This means that we have to pad
> @@ -36,7 +33,7 @@ static netdev_tx_t trailer_xmit(struct sk_buff *skb, struct net_device *dev)
>  	nskb = alloc_skb(NET_IP_ALIGN + skb->len + padlen + 4, GFP_ATOMIC);
>  	if (nskb == NULL) {
>  		kfree_skb(skb);
> -		return NETDEV_TX_OK;
> +		return -ENOMEM;

I just spotted this, this won't work since we allocated a new SKB, but
the transmit code will attempt to submit skb, not nskb, I will respin
this patch series, sorry for not noticing this earlier...

David, please discard this.
-- 
Florian
