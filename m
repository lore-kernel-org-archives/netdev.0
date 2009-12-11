From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Handle NETREG_UNINITIALIZED devices correctly
Date: Fri, 11 Dec 2009 15:12:18 -0800 (PST)
Message-ID: <20091211.151218.91435502.davem@davemloft.net>
References: <20091209082602.19053.97297.sendpatchset@localhost.localdomain>
	<4B1F7498.2090007@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58923
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757257AbZLKXMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 18:12:12 -0500
In-Reply-To: <4B1F7498.2090007@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 09 Dec 2009 10:57:44 +0100

> Krishna Kumar a écrit :
>> From: Krishna Kumar <krkumar2@in.ibm.com>
>> 
>> Fix two problems:
>> 
>> 1. If unregister_netdevice_many() is called with both registered
>>    and unregistered devices, rollback_registered_many() bails out
>>    when it reaches the first unregistered device. The processing
>>    of the prior registered devices is unfinished, and the
>>    remaining devices are skipped, and possible registered netdev's
>>    are leaked/unregistered.
>> 
>> 2. System hangs or panics depending on how the devices are passed,
>>    since when netdev_run_todo() runs, some devices were not fully
>>    processed.
>> 
>> Tested by passing intermingled unregistered and registered vlan
>> devices to unregister_netdevice_many() as follows:
>> 	1. dev, fake_dev1, fake_dev2: hangs in run_todo
>> 	   ("unregister_netdevice: waiting for eth1.100 to become
>> 	    free. Usage count = 1")
>> 	2. fake_dev1, dev, fake_dev2: failure during de-registration
>> 	   and next registration, followed by a vlan driver Oops
>> 	   during subsequent registration.
>> 
>> Confirmed that the patch fixes both cases.
>> 
>> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> 
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Nice work Krishna, applied, thanks!
