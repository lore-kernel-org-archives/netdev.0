From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: [PATCH] natsemi: silence dma-debug warnings
Date: Sun, 10 Jul 2011 10:57:30 +0900 (JST)
Message-ID: <20110710.105730.1305564732068163754.fujita.tomonori@lab.ntt.co.jp>
References: <CAJfuBxxKYNvaw5t4jWMP4+hYcw42SkwLiiahVdeezpfh6AsLBA@mail.gmail.com>
	<20110710.102039.1305564732068163396.fujita.tomonori@lab.ntt.co.jp>
	<CAJfuBxxs=CEBV+v+8GkYyabVobhwiXKYc5qHhZE-ZKFxywkQaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, thockin@hockin.org, netdev@vger.kernel.org
To: jim.cromie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:49728 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755214Ab1GJB5a convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2011 21:57:30 -0400
In-Reply-To: <CAJfuBxxs=CEBV+v+8GkYyabVobhwiXKYc5qHhZE-ZKFxywkQaQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 9 Jul 2011 19:45:22 -0600
Jim Cromie <jim.cromie@gmail.com> wrote:

> On Sat, Jul 9, 2011 at 7:20 PM, FUJITA Tomonori=0D
> <fujita.tomonori@lab.ntt.co.jp> wrote:
>> On Sat, 9 Jul 2011 14:11:25 -0600
>> Jim Cromie <jim.cromie@gmail.com> wrote:
>>
>>> On Sun, Jul 3, 2011 at 11:34 PM, David Miller <davem@davemloft.net>=
 wrote:
>>>> From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
>>>> Date: Mon, 4 Jul 2011 14:30:19 +0900
>>>>
>>>>> This silences dma-debug warnings:
>>>>>
>>>>> https://lkml.org/lkml/2011/6/30/341
>>>> =A0...
>>>>> Reported-by: Jim Cromie <jim.cromie@gmail.com>
>>>>> Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
>>>>> Tested-by: Jim Cromie <jim.cromie@gmail.com>
>>>>
>>>> Applied, thanks!
>>>>
>>>
>>> I have since seen a similar warning on shutdown,
>>> heres a patch for it.
>>
>> Oops, I noticed this too but I forgot to send a patch.
>>
>> The patch looks good to me.
>>
>>
>>> theres one other callsite, but I havent seen the warning from it,
>>> will try to tickle it at some point.
>>
>> Which pci_unmap_single are you talking about?
>>
>=20
>=20
>    2131 static void netdev_tx_done(struct net_device *dev)
>    2132 {
> ...
>    2160                 pci_unmap_single(np->pci_dev,np->tx_dma[entry=
],
>    2161                                         np->tx_skbuff[entry]-=
>len,
>    2162                                         PCI_DMA_TODEVICE);

It's pci_unmap_single call for tx_dma buffers. We fixed
pci_unmap_single calls for rx_dma buffers.

Looks like the driver correctlly uses pci_map_single and
pci_unmap_single for tx_dma buffers.
