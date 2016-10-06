From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: Re: [PATCH 3/3] net: smsc911x: add u16 workaround for pxa platforms
Date: Thu, 06 Oct 2016 08:47:13 +0200
Message-ID: <87lgy27z4e.fsf@belgarion.home>
References: <1475485553-18747-1-git-send-email-robert.jarzmik@free.fr>
        <1475485553-18747-3-git-send-email-robert.jarzmik@free.fr>
        <20161003154624.GG7632@leverpostej> <87oa319zv8.fsf@belgarion.home>
        <20161003165032.GB15313@leverpostej> <871szx9rhc.fsf@belgarion.home>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rob Herring <robh+dt@kernel.org>, Nicolas Pitre <nico@fluxnic.net>,
        Russell King - ARM Linux <linux@armlinux.org.uk>,
        Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <871szx9rhc.fsf@belgarion.home> (Robert Jarzmik's message of
        "Mon, 03 Oct 2016 21:12:31 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Robert Jarzmik <robert.jarzmik@free.fr> writes:

> Mark Rutland <mark.rutland@arm.com> writes:
>
>> On Mon, Oct 03, 2016 at 06:11:23PM +0200, Robert Jarzmik wrote:
>>> Mark Rutland <mark.rutland@arm.com> writes:
>>> 
>>> reg-u16-align4 tells that a specific hardware doesn't support 16 bit writes not
>>> being 32 bits aligned, or said differently that a "store" 16 bits wide on an
>>> address of the format 4*n + 2 deserves a special handling in the driver, while a
>>> store 16 bits wide on an address of the format 4*n can follow the simple casual
>>> case.
>>
>> If I've understood correctly, effectively the low 2 address lines to the
>> device are hard-wired to zero, e.g. a 16-bit access to 4*n + 2 would go
>> to 4*n + 0 on the device? Or is the failure case distinct from that?
> It is distinct.
>
> The "awful truth" is that an FPGA lies between the system bus and the
> smc91c111. And this FPGA cannot handle correctly the 4*n + 2 u16 writes.
>
>> Do we have other platforms where similar is true? e.g. u8 accesses
>> requiring 16-bit alignment?
>
> Not really, ie. not with a alignement requirement.
>
> But there are of course these ones are handled by reg-io-width and the
> SMC_USE_xxx_BITS flags as far as I understand it. These cases are when a
> platform declares SMC91X_USE_16BIT or SMC91X_USE_32BIT, but not SMC91X_USE_8BIT,
> which would make me think of :
>  - CONFIG_SH_SH4202_MICRODEV,
>  - CONFIG_M32R
>  - several omap1 boards
>  - 1 sa1100 board
>  - several MMP and realview boards
>
> With all these platforms, each u8 access is replaced with a u16 access and a
> mask / shift + mask.

Or so what should I call this entry if reg-u16-align4 is not a good candidate ?

Cheers.

-- 
Robert
