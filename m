From: Robert Hancock <hancockrwd@gmail.com>
Subject: Re: [Regression] r8169: enable 64-bit DMA by default for PCI Express
 devices (v2)
Date: Fri, 26 Mar 2010 19:55:44 -0600
Message-ID: <4BAD65A0.7090309@gmail.com>
References: <20100315150806.GA15354@Dublin.logfs.org> <20100315151041.GA15667@Dublin.logfs.org> <20100315.115748.13754030.davem@davemloft.net> <51f3faa71003151628g5edc4d7av8916ac76cb337bfe@mail.gmail.com> <20100316083501.GA3489@Dublin.logfs.org> <51f3faa71003161630g69160ea9tc1a2d448682632e5@mail.gmail.com> <51f3faa71003251756h17374375yd3a5d2acee2ffab9@mail.gmail.com> <20100326091234.GA11959@Dublin.logfs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	romieu@fr.zoreil.com
To: =?UTF-8?B?77+9IEVuZ2Vs?= <joern@dublin.logfs.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100326091234.GA11959@Dublin.logfs.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/26/2010 03:12 AM, =EF=BF=BD Engel wrote:
> On Thu, 25 March 2010 18:56:03 -0600, Robert Hancock wrote:
>>
>> Francois, ping? Is there anyone else that has access to this kind of
>> information about these chips?
>>
>> It's kind of interesting that there's only been one report of this
>> though. Either the affected chips are rare among people testing
>> 2.6.34-rc or there's something more to this. Maybe something
>> wierd/unusual about J=C3=B6rn's system?
>>
>> J=C3=B6rn, are any other devices on your system working with 64-bit
>> addressing? Try doing this:
>>
>> find /sys -name "*dma_mask_bits*" | xargs cat
>>
>> Does anything show more than 32?
>
> I've slightly changed the command:
> # for i in `find /sys -name "*dma_mask_bits*"`; do echo -n "$i: "; ca=
t $i; done
> /sys/devices/pci0000:00/0000:00:00.0/dma_mask_bits: 32
> /sys/devices/pci0000:00/0000:00:00.0/consistent_dma_mask_bits: 32
> /sys/devices/pci0000:00/0000:00:02.0/dma_mask_bits: 36
> /sys/devices/pci0000:00/0000:00:02.0/consistent_dma_mask_bits: 36
> /sys/devices/pci0000:00/0000:00:1c.0/dma_mask_bits: 32
> /sys/devices/pci0000:00/0000:00:1c.0/consistent_dma_mask_bits: 32
> /sys/devices/pci0000:00/0000:00:1c.1/dma_mask_bits: 32
> /sys/devices/pci0000:00/0000:00:1c.1/consistent_dma_mask_bits: 32
> /sys/devices/pci0000:00/0000:00:1c.1/0000:01:00.0/dma_mask_bits: 32
> /sys/devices/pci0000:00/0000:00:1c.1/0000:01:00.0/consistent_dma_mask=
_bits: 32
> /sys/devices/pci0000:00/0000:00:1d.0/dma_mask_bits: 32
> /sys/devices/pci0000:00/0000:00:1d.0/consistent_dma_mask_bits: 32
> /sys/devices/pci0000:00/0000:00:1d.1/dma_mask_bits: 32
> /sys/devices/pci0000:00/0000:00:1d.1/consistent_dma_mask_bits: 32
> /sys/devices/pci0000:00/0000:00:1d.2/dma_mask_bits: 32
> /sys/devices/pci0000:00/0000:00:1d.2/consistent_dma_mask_bits: 32
> /sys/devices/pci0000:00/0000:00:1d.3/dma_mask_bits: 32
> /sys/devices/pci0000:00/0000:00:1d.3/consistent_dma_mask_bits: 32
> /sys/devices/pci0000:00/0000:00:1d.7/dma_mask_bits: 32
> /sys/devices/pci0000:00/0000:00:1d.7/consistent_dma_mask_bits: 32
> /sys/devices/pci0000:00/0000:00:1e.0/dma_mask_bits: 32
> /sys/devices/pci0000:00/0000:00:1e.0/consistent_dma_mask_bits: 32
> /sys/devices/pci0000:00/0000:00:1f.0/dma_mask_bits: 32
> /sys/devices/pci0000:00/0000:00:1f.0/consistent_dma_mask_bits: 32
> /sys/devices/pci0000:00/0000:00:1f.1/dma_mask_bits: 32
> /sys/devices/pci0000:00/0000:00:1f.1/consistent_dma_mask_bits: 32
> /sys/devices/pci0000:00/0000:00:1f.2/dma_mask_bits: 32
> /sys/devices/pci0000:00/0000:00:1f.2/consistent_dma_mask_bits: 32
> /sys/devices/pci0000:00/0000:00:1f.3/dma_mask_bits: 32
> /sys/devices/pci0000:00/0000:00:1f.3/consistent_dma_mask_bits: 32
>
> One device, which should be this one:
> 00:02.0 VGA compatible controller: Intel Corporation 82G33/G31 Expres=
s Integrated Graphics Controller (rev 10)

Well, that one's 36 bits, but it's unclear whether that driver would=20
actually be likely to access anything over 4GB. It's possible that=20
there's just some general problem with 64-bit DMA on that machine.

The fact that even stuff like lspci and MII is breaking seems odd,=20
though. It could be that model of card doesn't like the PCIDAC register=
=20
bit being set (maybe it means something different on that model, or=20
something).

I suppose a publicly accessible datasheet for these chips is too much t=
o=20
hope for?
