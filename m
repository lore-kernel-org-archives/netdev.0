From: Ido Shamai <idos@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 2/2] net/mlx4: Revert "mlx4: set maximal number
 of default RSS queues"
Date: Wed, 15 Jan 2014 15:15:40 +0200
Message-ID: <52D689FC.8090408@dev.mellanox.co.il>
References: <1388581537-4810-1-git-send-email-amirv@mellanox.com>	<1388581537-4810-3-git-send-email-amirv@mellanox.com>	<979A8436335E3744ADCD3A9F2A2B68A52AF21A1A@SJEXCHMB10.corp.ad.broadcom.com> <CAJZOPZ++ETzuttO9_ZTy6Atx6=wKyhXUhxyQHj2Ed5nTUBNC0A@mail.gmail.com> <979A8436335E3744ADCD3A9F2A2B68A52AF21C13@SJEXCHMB10.corp.ad.broadcom.com> <52C532DB.9000200@mellanox.com> <979A8436335E3744ADCD3A9F2A2B68A52AF21E1F@SJEXCHMB10.corp.ad.broadcom.com> <52D67BFF.6070102@dev.mellanox.co.il> <979A8436335E3744ADCD3A9F2A2B68A52AF2849F@SJEXCHMB10.corp.ad.broadcom.com>
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
Received: from mail-ee0-f49.google.com ([74.125.83.49]:49294 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751502AbaAONPt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 08:15:49 -0500
Received: by mail-ee0-f49.google.com with SMTP id d17so864561eek.36
        for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 05:15:48 -0800 (PST)
In-Reply-To: <979A8436335E3744ADCD3A9F2A2B68A52AF2849F@SJEXCHMB10.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/15/2014 2:54 PM, Yuval Mintz wrote:
>>> Anyway, I believe 8/16 are simply strict limitations without any true
>> meaning;
>>> To judge what's more important, default `slimness' or default performance
>>> is beyond me.
>>> Perhaps the numa approach will prove beneficial (and will make some
>> sense).
>>
>> After reviewing all that was said, I feel there is no need to enforce
>> vendors with this strict limitation without any true meaning.
>>
>> The reverted commit you applied forces the driver to use 8 rings at max
>> at all time, without the possibility to change in flight using ethtool,
>> as it's enforced on the PCI driver at module init (restarting the en
>> driver with different of requested rings will not affect).
>> So it's crucial for performance oriented applications using mlx4_en.
>
> The rational is to prevent default misusage of resources, be them irq vectors
> memories for rings.
> Notice this is just the default - You can always re-request interrupts if the
> user explicitly requests a large number of rings;
> Although, if the driver is incapable of that (e.g., hw limitations), perhaps you
> should allocate a larger number of irq vectors during init and use a limitation
> on your default number of rings
> (that's assuming that irq vectors are really inexpensive on all machines).

I fully agree with you on that.
We will send a new patch that will limit the default number of rings to 
this limitation, and could be changed using set-channels ethtool 
interface. Number of IRQ vectors will be (max) of number of CPUs.
Yuval, thanks for clarifying.

>> Going through all Ethernet vendors I don't see this limitation enforced,
>> so this limitation has no true meaning (no fairness).
>> I think this patch should go in as is.
>> Ethernet vendors should use it this limitation when they desire.
>
> Might be true, but two wrongs don't make a right.
> I believe that either this limitation should be mandatory, or the functionality
> Should Not be included in the kernel as communal code and each driver
> should do as it pleases.
I agree, but this is a different discussion that should be held.
I agree, but this is a different discussion, which I hope to be held 
sometimes in the near future.
