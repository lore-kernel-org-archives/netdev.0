From: =?UTF-8?B?UmljaGFyZCBSw7ZqZm9ycw==?=
	<richard.rojfors@pelagicore.com>
Subject: Re: [PATCH] ks8842: Add module param for setting mac address
Date: Sun, 18 Apr 2010 23:35:47 +0200
Message-ID: <4BCB7B33.4040306@pelagicore.com>
References: <1271611557.24099.11.camel@debian> <1271620221.3679.265.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-h12.telenor.se ([62.127.194.5]:36885 "EHLO
	smtprelay-h12.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753511Ab0DRVfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Apr 2010 17:35:52 -0400
Received: from ipb3.telenor.se (ipb3.telenor.se [195.54.127.166])
	by smtprelay-h12.telenor.se (Postfix) with ESMTP id D2263D296
	for <netdev@vger.kernel.org>; Sun, 18 Apr 2010 23:36:30 +0200 (CEST)
In-Reply-To: <1271620221.3679.265.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/18/2010 09:50 PM, Ben Hutchings wrote:
> On Sun, 2010-04-18 at 19:25 +0200, Richard R=C3=B6jfors wrote:
>> This patch adds a module parameter for setting the MAC address.
>>
>> To ensure this MAC address is used, the MAC address is written
>> after each hardware reset.
> [...]
>
> This is not an accepted way of setting the MAC address.

I agree it's not the cleanest way of doing this, I saw  some of the
other drivers do like this.

>  The accepted ways to initialise a network controller's address are:
>
> 1. a. Controller reads it from dedicated NVRAM.  Driver reads it from
>        controller.
>     b. Driver reads it from dedicated NVRAM.

Not possible with the current hardware.

> 2. Platform firmware or boot loader passes platform data (OpenFirmwar=
e,
>     device tree, etc.) to the kernel, which includes the assigned MAC
>     address.  Driver uses kernel functions to read it from platform d=
ata.

On our system (X86 based) the ks8842 is connected via a FPGA, the FPGA =
is
connected via PCI express. The system has a standard BIOS.
In linux we have a MFD driver chunking up the PCI memory space into
platform devices. In that case we would need to feed the data as a para=
m
to the MFD driver which copies into the platform data of the ks8842, wo=
uld
be doable.

> 3. Platform firmware or boot loader programs it into the controller.
>     Driver reads it from the controller.

We use standard BIOS and boot loaders from the X86 distros -> more or l=
ess
not doable.

> 4. Driver generates random address.

That's the current fallback if none is given and the random address
in the chip isn't valid.

>
> In any case, userland can change the MAC address later.

If we don't need to have a known MAC before the root FS is mounted.

--Richard
