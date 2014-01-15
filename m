From: Ido Shamai <idos@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 2/2] net/mlx4: Revert "mlx4: set maximal number
 of default RSS queues"
Date: Wed, 15 Jan 2014 14:15:59 +0200
Message-ID: <52D67BFF.6070102@dev.mellanox.co.il>
References: <1388581537-4810-1-git-send-email-amirv@mellanox.com>	<1388581537-4810-3-git-send-email-amirv@mellanox.com>	<979A8436335E3744ADCD3A9F2A2B68A52AF21A1A@SJEXCHMB10.corp.ad.broadcom.com> <CAJZOPZ++ETzuttO9_ZTy6Atx6=wKyhXUhxyQHj2Ed5nTUBNC0A@mail.gmail.com> <979A8436335E3744ADCD3A9F2A2B68A52AF21C13@SJEXCHMB10.corp.ad.broadcom.com> <52C532DB.9000200@mellanox.com> <979A8436335E3744ADCD3A9F2A2B68A52AF21E1F@SJEXCHMB10.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: Yuval Mintz <yuvalmin@broadcom.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f169.google.com ([209.85.215.169]:64167 "EHLO
	mail-ea0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751913AbaAOMQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 07:16:25 -0500
Received: by mail-ea0-f169.google.com with SMTP id l9so366635eaj.28
        for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 04:16:24 -0800 (PST)
In-Reply-To: <979A8436335E3744ADCD3A9F2A2B68A52AF21E1F@SJEXCHMB10.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/2/2014 12:27 PM, Yuval Mintz wrote:
>>>> Going back to your original commit 16917b87a "net-next: Add
>>>> netif_get_num_default_rss_queues" I am still not clear why we want
>>>>
>>>> 1. why we want a common default to all MQ devices?
>>> Although networking benefits from multiple Interrupt vectors
>>> (enabling more rings, better performance, etc.), bounding this
>>> number only to the number of cpus is unreasonable as it strains
>>> system resources; e.g., consider a 40-cpu server - we might wish
>>> to have 40 vectors per device, but that means that connecting
>>> several devices to the same server might cause other functions
>>> to fail probe as they will no longer be able to acquire interrupt
>>> vectors of their own.
>>
>> Modern servers which have tens of CPUs typically have thousands of MSI-X
>> vectors which means you should be easily able to plug four cards into a
>> server with 64 cores which will consume 256 out of the 1-4K vectors out
>> there. Anyway, let me continue your approach - how about raising the
>> default hard limit to 16 or having it as the number of cores @ the numa
>> node where the card is plugged?
>
> I think an additional issue was memory consumption -
> additional interrupts --> additional allocated memory (for Rx rings).
> And I do know the issues were real - we've had complains about devices
> failing to load due to lack of resources (not all servers in the world are
> top of the art).
>
> Anyway, I believe 8/16 are simply strict limitations without any true meaning;
> To judge what's more important, default `slimness' or default performance
> is beyond me.
> Perhaps the numa approach will prove beneficial (and will make some sense).

After reviewing all that was said, I feel there is no need to enforce 
vendors with this strict limitation without any true meaning.

The reverted commit you applied forces the driver to use 8 rings at max 
at all time, without the possibility to change in flight using ethtool, 
as it's enforced on the PCI driver at module init (restarting the en 
driver with different of requested rings will not affect).
So it's crucial for performance oriented applications using mlx4_en.

Going through all Ethernet vendors I don't see this limitation enforced, 
so this limitation has no true meaning (no fairness).
I think this patch should go in as is.
Ethernet vendors should use it this limitation when they desire.

Ido
> Thanks,
> Yuval
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
