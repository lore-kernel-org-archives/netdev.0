From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [2.6 patch] wan/hdlc_x25.c: fix a NULL dereference
Date: Wed, 03 Sep 2008 10:12:34 -0400
Message-ID: <48BE9B52.8050003@garzik.org>
References: <20080827220549.GS11734@cs181140183.pp.htv.fi> <m3bpz9glik.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@kernel.org>, Jeff Garzik <jgarzik@redhat.com>,
	netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49426 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753933AbYICOMo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 10:12:44 -0400
In-Reply-To: <m3bpz9glik.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Halasa wrote:
> Adrian Bunk <bunk@kernel.org> writes:
> 
>> --- a/drivers/net/wan/hdlc_x25.c
>> +++ b/drivers/net/wan/hdlc_x25.c
>> @@ -163,10 +163,8 @@ static void x25_close(struct net_device *dev)
>>  
>>  static int x25_rx(struct sk_buff *skb)
>>  {
>> -	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL) {
>> -		skb->dev->stats.rx_dropped++;
>> +	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
>>  		return NET_RX_DROP;
>> -	}
>>  
> 
> Right, thanks... though I will update the stats anyway.

In terms of patches... what does this mean?  Does this mean you are 
taking Adrian's patch, and updating it?  Sending a follow-up patch? 
Ack'ing Adrian's patch?

I don't want to hold this back due to lack of stat update...

