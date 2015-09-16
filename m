From: "Simon Arlott" <simon@fire.lp0.eu>
Subject: Re: [PATCH RFC] solos-pci: Fix BUG() with shared skb
Date: Wed, 16 Sep 2015 12:32:06 +0100
Message-ID: <2f3c01599888e375610e85d20ad3e7ab16b00ba2@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid>
References: <1378223125.4210.11.camel@i7.infradead.org>
    <20130904.143056.1558570610941220565.davem@davemloft.net>
    <1378327275.2627.28.camel@shinybook.infradead.org>
    <1442344243.131189.26.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net
To: "David Woodhouse" <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([81.2.80.65]:48024 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751934AbbIPLjo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Sep 2015 07:39:44 -0400
In-Reply-To: <1442344243.131189.26.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, September 15, 2015 20:10, David Woodhouse wrote:
> On Wed, 2013-09-04 at 21:41 +0100, David Woodhouse wrote:
>> +++ b/drivers/atm/solos-pci.c
>> @@ -1145,19 +1145,19 @@ static int psend(struct atm_vcc *vcc, struct sk_buff *skb)
>> +> 	> if (skb_headroom(skb) < sizeof(*header)) {
>> +> 	> 	> struct sk_buff *nskb;
>> +
>> +> 	> 	> nskb = skb_realloc_headroom(skb, sizeof(*header));
>> +> 	> 	> if (!nskb) {
>> +> 	> 	> 	> solos_pop(vcc, skb);
>> +> 	> 	> 	> return -ENOMEM;
>> +> 	> 	> }
>> +> 	> 	> if (skb->truesize != nskb->truesize)
>> +> 	> 	> 	> atm_force_charge(vcc, nskb->truesize - skb->truesize);
>> +
>> +> 	> 	> dev_kfree_skb_any(skb);
>> +> 	> 	> skb = nskb;
>>  > 	> }
>
> Simon, did you ever test this?
> Can you still (tell me how to) reproduce the original problem? I think
> that sending on br2684 was necessary but not sufficient...?

I'm currently using this but without the call to atm_force_charge().

I don't know how to reproduce the BUG() but it hasn't happened again.

-- 
Simon Arlott
