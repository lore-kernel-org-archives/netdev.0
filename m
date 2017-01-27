From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net: bgmac: allocate struct bgmac just once &
 don't copy it
Date: Fri, 27 Jan 2017 11:14:50 -0500 (EST)
Message-ID: <20170127.111450.1252941253517746124.davem@davemloft.net>
References: <20170127092043.17413-1-zajec5@gmail.com>
        <20170127092043.17413-2-zajec5@gmail.com>
        <8bb6614b-a4af-d435-7db8-616cb1c1a56d@nbd.name>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: 8bit
Cc: zajec5@gmail.com, jon.mason@broadcom.com, f.fainelli@gmail.com,
        nbd@openwrt.org, netdev@vger.kernel.org, rafal@milecki.pl
To: nbd@nbd.name
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39170 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754726AbdA0Q0q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 11:26:46 -0500
In-Reply-To: <8bb6614b-a4af-d435-7db8-616cb1c1a56d@nbd.name>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Fietkau <nbd@nbd.name>
Date: Fri, 27 Jan 2017 17:02:33 +0100

> On 2017-01-27 10:20, Rafa©© Mi©©ecki wrote:
>> From: Rafa©© Mi©©ecki <rafal@milecki.pl>
>> 
>> To share as much code as possible in bgmac we call alloc_etherdev from
>> bgmac.c which is used by both: platform and bcma code. The easiest
>> solution was to use it for allocating whole struct bgmac but it doesn't
>> work well as we already get early-filled struct bgmac as an argument.
>> 
>> So far we were solving this by copying received struct into newly
>> allocated one. The problem is it means storing 2 allocated structs,
>> using only 1 of them and non-shared code not having access to it.
>> 
>> This patch solves it by using alloc_etherdev to allocate *pointer* for
>> the already allocated struct. The only downside of this is we have to be
>> careful when using netdev_priv.
>> 
>> Another solution was to call alloc_etherdev in platform/bcma specific
>> code but Jon advised against it due to sharing less code that way.
> How does that lead to sharing less code?
> I find this pointer indirection rather ugly and uncommon, and I think it
> would be much cleaner to split the probe into bgmac_enet_alloc and
> bgmac_enet_probe (with bgmac_enet_alloc calling alloc_etherdev and doing
> basic setup).

I agree, it would be so much better if bgmac_probe() and friends
initialized a real bgmac object which was the private of a netdev
struct, then passed that down into bgmac_enet_probe().
