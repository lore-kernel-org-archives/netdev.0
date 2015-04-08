From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] sfc: Own header for nic-specific sriov
 functions, single instance of netdev_ops and sriov removed from Falcon code
Date: Wed, 08 Apr 2015 16:28:42 -0400 (EDT)
Message-ID: <20150408.162842.1573769781306113806.davem@davemloft.net>
References: <55253A2D.8090901@solarflare.com>
	<1428522763.25985.222.camel@edumazet-glaptop2.roam.corp.google.com>
	<1428523025.25985.224.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sshah@solarflare.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41143 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753905AbbDHU2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 16:28:45 -0400
In-Reply-To: <1428523025.25985.224.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 08 Apr 2015 12:57:05 -0700

> On Wed, 2015-04-08 at 12:52 -0700, Eric Dumazet wrote:
>> On Wed, 2015-04-08 at 15:24 +0100, Shradha Shah wrote:
>>   CC [M]  drivers/net/ethernet/sfc/qt202x_phy.o
>> drivers/net/ethernet/sfc/siena.c:1008:22: error: 'efx_siena_sriov_set_vf_mac' undeclared here (not in a function)
>> drivers/net/ethernet/sfc/siena.c:1009:23: error: 'efx_siena_sriov_set_vf_vlan' undeclared here (not in a function)
>> drivers/net/ethernet/sfc/siena.c:1010:27: error: 'efx_siena_sriov_set_vf_spoofchk' undeclared here (not in a function)
>> drivers/net/ethernet/sfc/siena.c:1011:25: error: 'efx_siena_sriov_get_vf_config' undeclared here (not in a function)
>>   CC [M]  drivers/net/ethernet/sfc/mdio_10g.o
>> make[5]: *** [drivers/net/ethernet/sfc/siena.o] Error 1
>> make[5]: *** Waiting for unfinished jobs....
>> drivers/net/ethernet/sfc/ef10.c:3700:22: error: 'efx_ef10_sriov_set_vf_mac' undeclared here (not in a function)
>> drivers/net/ethernet/sfc/ef10.c:3701:23: error: 'efx_ef10_sriov_set_vf_vlan' undeclared here (not in a function)
>> drivers/net/ethernet/sfc/ef10.c:3702:27: error: 'efx_ef10_sriov_set_vf_spoofchk' undeclared here (not in a function)
>> drivers/net/ethernet/sfc/ef10.c:3703:25: error: 'efx_ef10_sriov_get_vf_config' undeclared here (not in a function)
>> make[5]: *** [drivers/net/ethernet/sfc/ef10.o] Error 1
>> 
> 
> Please test your driver with :
> 
> $ grep PCI_IOV .config
> # CONFIG_PCI_IOV is not set
> $ grep SFC_SRIOV .config
> $ 

This is really terrible.

siena_sriov.c is only build when CONFIG_SFC_SRIOV is enabled, but it has
CONFIG_SFC_SRIOV CPP checks all over the file.  I don't know what better
can define a low quality patch submission...

I tried to fix this up, but it's way too broken for a quick cure,
therefore I'm reverting everything.
