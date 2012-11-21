From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: 8139cp: set ring address before enabling receiver
Date: Wed, 21 Nov 2012 15:40:49 -0500
Message-ID: <50AD3C51.9070105@pobox.com>
References: <20120602235020.2C0A57C006C@ra.kernel.org> <1353517042.26346.130.camel@shinybook.infradead.org> <50AD1972.5080403@pobox.com> <1353527481.26346.150.camel@shinybook.infradead.org> <1353529135.2619.36.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Woodhouse <dwmw2@infradead.org>,
	Jason Wang <jasowang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:60918 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964826Ab2KUUkx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 15:40:53 -0500
Received: by mail-vb0-f46.google.com with SMTP id ff1so2077764vbb.19
        for <netdev@vger.kernel.org>; Wed, 21 Nov 2012 12:40:52 -0800 (PST)
In-Reply-To: <1353529135.2619.36.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/21/2012 03:18 PM, Ben Hutchings wrote:
> On Wed, 2012-11-21 at 19:51 +0000, David Woodhouse wrote:
>> On Wed, 2012-11-21 at 13:12 -0500, Jeff Garzik wrote:
>>>
>>> What sticks out at me from the commit message?
>>>
>>> It was not tested on the famously quirky 8139 hardware at all.
>>>
>>> While I have not looked at the 8139C+ data sheet in a while, someti=
mes
>>> the hardware _did_ have a strange init order.
>>>
>>> As this works in a simulator but fails on real hardware, it seems l=
ike
>>> an obvious regression caused by an untested [on read hardware] patc=
h.
>>
>> The data sheet (v1.6, from http://realtek.info/pdf/rtl8139cp.pdf ) s=
ays
>> in =C2=A76.33 (C+ Command Register):
>>   "Enable C+ mode functions in C+CR register first,
>>   =3D> Enable transmit/receive in Command register (offset 37h),
>>   =3D> Configure other related registers (ex. Descriptor start addre=
ss,
>>      TCR, RCR, ...)."
>>
>> I understand the concern expressed in the offending commit message a=
bout
>> DMA happening to invalid addresses, and I'll look at the data sheet
>> harder to see when the DMA actually starts happening. But it definit=
ely
>> seems that our current code isn't doing what the data sheet says.
>>
>> I wonder if I can find one of these lying around and stick it in a
>> machine with an IOMMU...
>
> You might be able to avoid disaster by doing:
>
> 1. Set MAC filter to drop everything
> 2. Enable RX DMA
> 3. Set RX DMA ring address
> 4. Set MAC filter according to current flags & multicast list
>
> I'm assuming, knowing nothing about this particular hardware, that th=
e
> MAC filter register(s) will accept writes before RX DMA is enabled.

A larger point is that the commit was created to avoid imagined disaste=
r=20
on simulated hardware...

  ...and wound up creating behavior that is (a) contra to the data shee=
t=20
and (b) breaks real hardware.

	Jeff
