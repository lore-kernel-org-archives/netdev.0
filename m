From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: Re: [BUG] 2.6.29-rc* QinQ vlan trunking regression
Date: Thu, 05 Mar 2009 09:05:42 +0100
Message-ID: <49AF87D6.5040104@linux.vnet.ibm.com>
References: <49AF79A6.6030002@trash.net>	<20090304.231120.86999183.davem@davemloft.net>	<49AF7B72.2020905@trash.net> <20090304.231911.213286076.davem@davemloft.net> <49AF7E93.2010800@trash.net> <49AF7FD3.5010709@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bart@jukie.net,
	greearb@candelatech.com, shemminger@vyatta.com,
	dada1@cosmosbay.com, frank.blaschka@de.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([194.196.100.161]:52482 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751280AbZCEIFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 03:05:49 -0500
In-Reply-To: <49AF7FD3.5010709@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, Patrick,

sorry I could not follow the complete discussion of the fixes done for this problem
but does

 	if (netif_device_present(real_dev) && ops->ndo_neigh_setup)
-		err = ops->ndo_neigh_setup(dev, pa);
+		err = ops->ndo_neigh_setup(real_dev, pa);

not change the idea of the neigh_setup? Remind we want the neigh_setup of the
real device as the neigh setup function for the vlan device.

Frank

Patrick McHardy schrieb:
> Patrick McHardy wrote:
>> David Miller wrote:
>>> From: Patrick McHardy <kaber@trash.net>
>>> Date: Thu, 05 Mar 2009 08:12:50 +0100
>>>
>>>>> We probably need both fixes to cover everything.
>>>>>
>>>> Yes, just the second one still crashes. I'm about to retry using both.
>>>
>>> Here is the updated version just for the record:
>>>
>>> vlan: Fix vlan-in-vlan crashes.
>>
>> This still crashes. I'll have another look at the code.
> 
> This one combined with your patch fixes the crash. The code was calling
> vlan_dev_neigh_setup recursively.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> (or Tested-by: in case you want to roll it into your patch).
> 


