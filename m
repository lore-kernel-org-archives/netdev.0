From: Patrick McHardy <kaber@trash.net>
Subject: Re: [BUG] 2.6.29-rc* QinQ vlan trunking regression
Date: Thu, 05 Mar 2009 08:31:31 +0100
Message-ID: <49AF7FD3.5010709@trash.net>
References: <49AF79A6.6030002@trash.net>	<20090304.231120.86999183.davem@davemloft.net>	<49AF7B72.2020905@trash.net> <20090304.231911.213286076.davem@davemloft.net> <49AF7E93.2010800@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070605060506070304070407"
Cc: bart@jukie.net, greearb@candelatech.com, shemminger@vyatta.com,
	dada1@cosmosbay.com, frank.blaschka@de.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59891 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753565AbZCEHbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 02:31:35 -0500
In-Reply-To: <49AF7E93.2010800@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070605060506070304070407
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> David Miller wrote:
>> From: Patrick McHardy <kaber@trash.net>
>> Date: Thu, 05 Mar 2009 08:12:50 +0100
>>
>>>> We probably need both fixes to cover everything.
>>>>
>>> Yes, just the second one still crashes. I'm about to retry using both.
>>
>> Here is the updated version just for the record:
>>
>> vlan: Fix vlan-in-vlan crashes.
> 
> This still crashes. I'll have another look at the code.

This one combined with your patch fixes the crash. The code was calling
vlan_dev_neigh_setup recursively.

Signed-off-by: Patrick McHardy <kaber@trash.net>

(or Tested-by: in case you want to roll it into your patch).

--------------070605060506070304070407
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 4a19acd..1b34135 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -553,7 +553,7 @@ static int vlan_dev_neigh_setup(struct net_device *dev, struct neigh_parms *pa)
 	int err = 0;
 
 	if (netif_device_present(real_dev) && ops->ndo_neigh_setup)
-		err = ops->ndo_neigh_setup(dev, pa);
+		err = ops->ndo_neigh_setup(real_dev, pa);
 
 	return err;
 }

--------------070605060506070304070407--
