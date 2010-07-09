From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [PATCH] igbvf: avoid name clash between PF and VF
Date: Fri, 9 Jul 2010 08:33:24 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755EA8339B6@orsmsx508.amr.corp.intel.com>
References: <4C2B0614.9040004@redhat.com> <201007081541.57685.arnd@arndb.de>
 <4C36EC7D.5080800@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Andy Gospodarek <gospo@redhat.com>
To: Stefan Assmann <sassmann@redhat.com>, Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56637 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757215Ab0GIPd0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 11:33:26 -0400
In-Reply-To: <4C36EC7D.5080800@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Stefan Assmann [mailto:sassmann@redhat.com]
>Sent: Friday, July 09, 2010 2:32 AM
>To: Arnd Bergmann
>Cc: netdev; e1000-devel@lists.sourceforge.net; Duyck, Alexander H; Rose,
>Gregory V; Kirsher, Jeffrey T; Andy Gospodarek
>Subject: Re: [PATCH] igbvf: avoid name clash between PF and VF
>
>On 08.07.2010 15:41, Arnd Bergmann wrote:
>> On Wednesday 30 June 2010, Stefan Assmann wrote:
>>> diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
>>> index 5e2b2a8..2fb665b 100644
>>> --- a/drivers/net/igbvf/netdev.c
>>> +++ b/drivers/net/igbvf/netdev.c
>>> @@ -2787,7 +2787,7 @@ static int __devinit igbvf_probe(struct pci_dev
>*pdev,
>>>         netif_carrier_off(netdev);
>>>         netif_stop_queue(netdev);
>>>
>>> -       strcpy(netdev->name, "eth%d");
>>> +       strcpy(netdev->name, "veth%d");
>>>         err = register_netdev(netdev);
>>>         if (err)
>>>                 goto err_hw_init;
>>
>> Note that 'veth' is the name used for a virtual ethernet pair by
>> drivers/net/veth.c. If a variant of your patch gets applied, it would
>> probably be useful to use a different naming scheme to avoid confusion
>> with the veth driver.
>
>Good point!
>Greg suggested vfeth, that should be more descriptive and unique.
>
>  Stefan
>---
>diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
>index 5e2b2a8..4d02af8 100644
>--- a/drivers/net/igbvf/netdev.c
>+++ b/drivers/net/igbvf/netdev.c
>@@ -2787,7 +2787,7 @@ static int __devinit igbvf_probe(struct pci_dev
>*pdev,
> 	netif_carrier_off(netdev);
> 	netif_stop_queue(netdev);
>
>-	strcpy(netdev->name, "eth%d");
>+	strcpy(netdev->name, "vfeth%d");
> 	err = register_netdev(netdev);
> 	if (err)
> 		goto err_hw_init;

Acked-by: Greg Rose <gregory.v.rose@intel.com>

