From: Petri Gynther <pgynther@google.com>
Subject: Re: [PATCH] ibm_newemac: emac_close() needs to call
	netif_carrier_off()
Date: Wed, 19 Aug 2009 14:40:48 -0700
Message-ID: <fc21faff0908191440p5db84f79h8bb8a73501facae1@mail.gmail.com>
References: <20090819210000.D56AB254211@localhost>
	 <20090819141136.74f5c266@s6510>
	 <20090819.143403.27319428.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, benh@kernel.crashing.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:60371 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752918AbZHSVkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 17:40:51 -0400
Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id n7JLeoIh011907
	for <netdev@vger.kernel.org>; Wed, 19 Aug 2009 22:40:51 +0100
Received: from rv-out-0506.google.com (rvbl9.prod.google.com [10.140.88.9])
	by spaceape14.eur.corp.google.com with ESMTP id n7JLegq1022244
	for <netdev@vger.kernel.org>; Wed, 19 Aug 2009 14:40:48 -0700
Received: by rv-out-0506.google.com with SMTP id l9so1322453rvb.23
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2009 14:40:48 -0700 (PDT)
In-Reply-To: <20090819.143403.27319428.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I agree with David. And, that's why I propose this diff for
ibm_newemac driver as well.

On Wed, Aug 19, 2009 at 2:34 PM, David Miller<davem@davemloft.net> wrote:
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 19 Aug 2009 14:11:36 -0700
>
>> On Wed, 19 Aug 2009 14:00:00 -0700 (PDT)
>> Petri Gynther <pgynther@google.com> wrote:
>>
>>> When ibm_newemac netdev instance is shutdown with "ifconfig down",
>>> the netdev interface does not go properly down. netif_carrier_ok()
>>> keeps returning TRUE even after "ifconfig down".
>>>
>>> The problem can be seen when ibm_newemac instances are slaves of
>>> a bonding interface. The bonding interface code uses netif_carrier_ok()
>>> to determine the link status of its slaves. When ibm_newemac slave is
>>> shutdown with "ifconfig down", the bonding interface won't detect any
>>> link status change because netif_carrier_ok() keeps returning TRUE.
>>
>> Bonding should be testing for netif_running() && netif_carrier_ok().
>>
>> In many devices state of carrier is undefined when device is down.
>
> But if you check all of the drivers, ethernet in particular, the
> convention is to call netif_carrier_off() in foo_close().
>
