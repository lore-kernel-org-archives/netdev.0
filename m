From: Thomas Klein <osstklei@de.ibm.com>
Subject: Re: [PATCH] ehea: Fix IPv6 support
Date: Tue, 25 Mar 2008 16:41:04 +0100
Message-ID: <47E91D10.5060607@de.ibm.com>
References: <200803191355.44266.osstklei@de.ibm.com> <20080320145456.f0b6d101.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, raisch@de.ibm.com, themann@de.ibm.com,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, stefan.roscher@de.ibm.com,
	hering2@de.ibm.com, stable@kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:8142 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756020AbYCYPlK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 11:41:10 -0400
In-Reply-To: <20080320145456.f0b6d101.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> On Wed, 19 Mar 2008 13:55:43 +0100
> Thomas Klein <osstklei@de.ibm.com> wrote:
> 
>> Indicate that HEA calculates IPv4 checksums only
>>
>> Signed-off-by: Thomas Klein <tklein@de.ibm.com>
>>
>> ---
>> diff -Nurp -X dontdiff linux-2.6.25-rc6/drivers/net/ehea/ehea.h patched_kernel/drivers/net/ehea/ehea.h
>> --- linux-2.6.25-rc6/drivers/net/ehea/ehea.h	2008-03-17 00:32:14.000000000 +0100
>> +++ patched_kernel/drivers/net/ehea/ehea.h	2008-03-19 08:58:07.000000000 +0100
>> @@ -40,7 +40,7 @@
>>  #include <asm/io.h>
>>  
>>  #define DRV_NAME	"ehea"
>> -#define DRV_VERSION	"EHEA_0087"
>> +#define DRV_VERSION	"EHEA_0089"
>>  
>>  /* eHEA capability flags */
>>  #define DLPAR_PORT_ADD_REM 1
>> diff -Nurp -X dontdiff linux-2.6.25-rc6/drivers/net/ehea/ehea_main.c patched_kernel/drivers/net/ehea/ehea_main.c
>> --- linux-2.6.25-rc6/drivers/net/ehea/ehea_main.c	2008-03-17 00:32:14.000000000 +0100
>> +++ patched_kernel/drivers/net/ehea/ehea_main.c	2008-03-19 08:58:07.000000000 +0100
>> @@ -3108,7 +3108,7 @@ struct ehea_port *ehea_setup_single_port
>>  	dev->vlan_rx_add_vid = ehea_vlan_rx_add_vid;
>>  	dev->vlan_rx_kill_vid = ehea_vlan_rx_kill_vid;
>>  	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO
>> -		      | NETIF_F_HIGHDMA | NETIF_F_HW_CSUM | NETIF_F_HW_VLAN_TX
>> +		      | NETIF_F_HIGHDMA | NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_TX
>>  		      | NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER
>>  		      | NETIF_F_LLTX;
>>  	dev->tx_timeout = &ehea_tx_watchdog;
> 
> That looks like a pretty significant fix to me?  Should it be backported to
> 2.6.24.x?

Agreed. I'll send a patch.

Thomas
