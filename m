From: RongQing Li <roy.qing.li@gmail.com>
Subject: Re: [PATCH 2/2] ksz884x: fix Endian
Date: Mon, 9 Jul 2012 13:26:41 +0800
Message-ID: <CAJFZqHzm7=-PpsiNZJ9TgkDY2bt5WW7XwY6nBOa_E4eerRh1pg@mail.gmail.com>
References: <1341454003-11227-1-git-send-email-roy.qing.li@gmail.com>
	<1341614416.2923.12.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Tristram.Ha@micrel.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:35600 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751043Ab2GIF0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 01:26:42 -0400
Received: by obbuo13 with SMTP id uo13so20012027obb.19
        for <netdev@vger.kernel.org>; Sun, 08 Jul 2012 22:26:41 -0700 (PDT)
In-Reply-To: <1341614416.2923.12.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/7/7, Ben Hutchings <bhutchings@solarflare.com>:
> On Thu, 2012-07-05 at 10:06 +0800, roy.qing.li@gmail.com wrote:
>> From: Li RongQing <roy.qing.li@gmail.com>
>>
>> ETH_P_IP is host Endian, skb->protocol is big Endian, when
>> compare them, we should change skb->protocol from big endian
>> to host endian, ntohs, not htons.
>>
>> CC: Tristram Ha <Tristram.Ha@micrel.com>
>> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
>> ---
>>  drivers/net/ethernet/micrel/ksz884x.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/micrel/ksz884x.c
>> b/drivers/net/ethernet/micrel/ksz884x.c
>> index eaf9ff0..d9727f7 100644
>> --- a/drivers/net/ethernet/micrel/ksz884x.c
>> +++ b/drivers/net/ethernet/micrel/ksz884x.c
>> @@ -4882,7 +4882,7 @@ static netdev_tx_t netdev_tx(struct sk_buff *skb,
>> struct net_device *dev)
>>  	if (left) {
>>  		if (left < num ||
>>  				((CHECKSUM_PARTIAL == skb->ip_summed) &&
>> -				(ETH_P_IPV6 == htons(skb->protocol)))) {
>> +				(ETH_P_IPV6 == ntohs(skb->protocol)))) {
>
> This should really be changed to the idiomatic 'skb->protocol ==
> htons(ETH_P_IPV6)'.  For the current code, the compiler will probably
> generate a run-time byte-swap for little-endian systems.
>
> Ben.
>
>>  			struct sk_buff *org_skb = skb;
>>
>>  			skb = netdev_alloc_skb(dev, org_skb->len);
>
> --
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
>
>
