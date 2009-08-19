From: Petri Gynther <pgynther@google.com>
Subject: Re: [PATCH] ibm_newemac: emac_close() needs to call
	netif_carrier_off()
Date: Wed, 19 Aug 2009 15:32:41 -0700
Message-ID: <fc21faff0908191532i2de570a1g1a6674bf5fe64a05@mail.gmail.com>
References: <20090819210000.D56AB254211@localhost>
	 <20090819141136.74f5c266@s6510>
	 <20090819.143403.27319428.davem@davemloft.net>
	 <fc21faff0908191440p5db84f79h8bb8a73501facae1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, benh@kernel.crashing.org,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:50767 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753213AbZHSWcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 18:32:43 -0400
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id n7JMWi03028136
	for <netdev@vger.kernel.org>; Wed, 19 Aug 2009 15:32:45 -0700
Received: from rv-out-0708.google.com (rvfc5.prod.google.com [10.140.180.5])
	by wpaz29.hot.corp.google.com with ESMTP id n7JMWg0m010739
	for <netdev@vger.kernel.org>; Wed, 19 Aug 2009 15:32:42 -0700
Received: by rv-out-0708.google.com with SMTP id c5so1119799rvf.2
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2009 15:32:41 -0700 (PDT)
In-Reply-To: <fc21faff0908191440p5db84f79h8bb8a73501facae1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen,

I think your suggestion of adding netif_running() check to
bond_check_dev_link() is valid and a good fix to the bonding driver.
We can do this in a separate patch.

However, I think that the change to ibm_newemac: emac_close() is
needed as well. ibm_newemac netdevs should not return
netif_carrier_ok() == TRUE when they have been shut down.

On Wed, Aug 19, 2009 at 2:40 PM, Petri Gynther<pgynther@google.com> wrote:
> I agree with David. And, that's why I propose this diff for
> ibm_newemac driver as well.
>
> On Wed, Aug 19, 2009 at 2:34 PM, David Miller<davem@davemloft.net> wrote:
>> From: Stephen Hemminger <shemminger@vyatta.com>
>> Date: Wed, 19 Aug 2009 14:11:36 -0700
>>
>>> On Wed, 19 Aug 2009 14:00:00 -0700 (PDT)
>>> Petri Gynther <pgynther@google.com> wrote:
>>>
>>>> When ibm_newemac netdev instance is shutdown with "ifconfig down",
>>>> the netdev interface does not go properly down. netif_carrier_ok()
>>>> keeps returning TRUE even after "ifconfig down".
>>>>
>>>> The problem can be seen when ibm_newemac instances are slaves of
>>>> a bonding interface. The bonding interface code uses netif_carrier_ok()
>>>> to determine the link status of its slaves. When ibm_newemac slave is
>>>> shutdown with "ifconfig down", the bonding interface won't detect any
>>>> link status change because netif_carrier_ok() keeps returning TRUE.
>>>
>>> Bonding should be testing for netif_running() && netif_carrier_ok().
>>>
>>> In many devices state of carrier is undefined when device is down.
>>
>> But if you check all of the drivers, ethernet in particular, the
>> convention is to call netif_carrier_off() in foo_close().
>>
>
