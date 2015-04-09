From: Shradha Shah <sshah@solarflare.com>
Subject: Re: [PATCH net-next 1/2] sfc: Own header for nic-specific sriov functions,
 single instance of netdev_ops and sriov removed from Falcon code
Date: Thu, 9 Apr 2015 10:54:01 +0100
Message-ID: <55264C39.4090503@solarflare.com>
References: <55253A2D.8090901@solarflare.com>	<1428522763.25985.222.camel@edumazet-glaptop2.roam.corp.google.com>	<1428523025.25985.224.camel@edumazet-glaptop2.roam.corp.google.com> <20150408.162842.1573769781306113806.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>, <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:21229 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754976AbbDIJyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 05:54:11 -0400
In-Reply-To: <20150408.162842.1573769781306113806.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/04/15 21:28, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 08 Apr 2015 12:57:05 -0700
> 
>> On Wed, 2015-04-08 at 12:52 -0700, Eric Dumazet wrote:
>>> On Wed, 2015-04-08 at 15:24 +0100, Shradha Shah wrote:
>>>   CC [M]  drivers/net/ethernet/sfc/qt202x_phy.o
>>> drivers/net/ethernet/sfc/siena.c:1008:22: error: 'efx_siena_sriov_set_vf_mac' undeclared here (not in a function)
>>> drivers/net/ethernet/sfc/siena.c:1009:23: error: 'efx_siena_sriov_set_vf_vlan' undeclared here (not in a function)
>>> drivers/net/ethernet/sfc/siena.c:1010:27: error: 'efx_siena_sriov_set_vf_spoofchk' undeclared here (not in a function)
>>> drivers/net/ethernet/sfc/siena.c:1011:25: error: 'efx_siena_sriov_get_vf_config' undeclared here (not in a function)
>>>   CC [M]  drivers/net/ethernet/sfc/mdio_10g.o
>>> make[5]: *** [drivers/net/ethernet/sfc/siena.o] Error 1
>>> make[5]: *** Waiting for unfinished jobs....
>>> drivers/net/ethernet/sfc/ef10.c:3700:22: error: 'efx_ef10_sriov_set_vf_mac' undeclared here (not in a function)
>>> drivers/net/ethernet/sfc/ef10.c:3701:23: error: 'efx_ef10_sriov_set_vf_vlan' undeclared here (not in a function)
>>> drivers/net/ethernet/sfc/ef10.c:3702:27: error: 'efx_ef10_sriov_set_vf_spoofchk' undeclared here (not in a function)
>>> drivers/net/ethernet/sfc/ef10.c:3703:25: error: 'efx_ef10_sriov_get_vf_config' undeclared here (not in a function)
>>> make[5]: *** [drivers/net/ethernet/sfc/ef10.o] Error 1
>>>
>>
>> Please test your driver with :
>>
>> $ grep PCI_IOV .config
>> # CONFIG_PCI_IOV is not set
>> $ grep SFC_SRIOV .config
>> $ 
> 
> This is really terrible.

I apologize. I will correct this in net_driver.h
> 
> siena_sriov.c is only build when CONFIG_SFC_SRIOV is enabled, but it has
> CONFIG_SFC_SRIOV CPP checks all over the file.  I don't know what better
> can define a low quality patch submission...

siena_sriov.c is not a new file. I think a cleanup patch for cleaning up all
the CONFIG_SFC_SRIOV CPP checks is required before I post any new patches.

Will correct and send out a v2.

> 
> I tried to fix this up, but it's way too broken for a quick cure,
> therefore I'm reverting everything.
> 

-- 
Many Thanks,
Regards,
Shradha Shah
