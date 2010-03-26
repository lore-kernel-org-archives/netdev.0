From: Robert Hancock <hancockrwd@gmail.com>
Subject: Re: [Regression] r8169: enable 64-bit DMA by default for PCI Express
	devices (v2)
Date: Thu, 25 Mar 2010 18:56:03 -0600
Message-ID: <51f3faa71003251756h17374375yd3a5d2acee2ffab9@mail.gmail.com>
References: <20100315150806.GA15354@Dublin.logfs.org>
	 <20100315151041.GA15667@Dublin.logfs.org>
	 <20100315.115748.13754030.davem@davemloft.net>
	 <51f3faa71003151628g5edc4d7av8916ac76cb337bfe@mail.gmail.com>
	 <20100316083501.GA3489@Dublin.logfs.org>
	 <51f3faa71003161630g69160ea9tc1a2d448682632e5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	romieu@fr.zoreil.com
To: =?ISO-8859-1?Q?J=F6rn_Engel?= <joern@dublin.logfs.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51f3faa71003161630g69160ea9tc1a2d448682632e5@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 16, 2010 at 5:30 PM, Robert Hancock <hancockrwd@gmail.com> =
wrote:
> On Tue, Mar 16, 2010 at 2:35 AM, J=F6rn Engel <joern@dublin.logfs.org=
> wrote:
>> On Mon, 15 March 2010 17:28:45 -0600, Robert Hancock wrote:
>>>
>>> What are the symptoms?
>>
>> No more network. :)
>>
>> According to ifconfig the interface is up and running. =A0If I read
>> /sys/class/net/eth0 correctly, two packets have been sent and none
>> received. =A0LED on network card and switch is off. =A0mii-tool is
>> unhappy.
>>
>> With patch in:
>> Bikini:~# mii-tool
>> =A0No MII transceiver present!.
>>
>> With patch reverted:
>> Bikini:~# mii-tool
>> eth0: negotiated 100baseTx-FD flow-control, link ok
>>
>> I just noticed lspci is also unhappy.
>>
>> With patch in:
>> Bikini:~# lspci -vv > lspci
>> pcilib: sysfs_read_vpd: read failed: Connection timed out.
>>
>> With patch reverted:
>> Bikini:~# lspci -vv > lspci2
>> Bikini:~# diff -u lspci*
>> --- lspci =A0 =A0 =A0 2010-03-16 09:03:02.000000000 +0100
>> +++ lspci2 =A0 =A0 =A02010-03-16 09:09:36.000000000 +0100
>> @@ -246,7 +246,7 @@
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Vector table: BAR=3D4 offset=3D000000=
00
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0PBA: BAR=3D4 offset=3D00000800
>> =A0 =A0 =A0 =A0Capabilities: [cc] Vital Product Data
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 Not readable
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 Unknown small resource type 00, will n=
ot decode more.
>> =A0 =A0 =A0 =A0Capabilities: [100] Advanced Error Reporting
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0UESta: =A0DLP- SDES- TLP- FCP- CmpltT=
O- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0UEMsk: =A0DLP- SDES- TLP- FCP- CmpltT=
O- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
>>
>> As you might expect, delta is part of the ethernet controller.
>>
>> All "With patch in" output above is typed off the screen. =A0Beware =
of
>> typos.
>>
>>> Does setting use_dac=3D0 in the module options
>>> for r8169 also resolve the problem?
>>
>> /sys/modules/r8169 does not exist. =A0How odd. =A0Anyway, simply cha=
nging
>> the default in r8169.c to 0 fixes the problems for me. =A0Good call.
>
>
> I can't really explain how the MII and lspci output is being
> affected.. However, it's possible that some of the chips supported by
> this driver don't actually support 64-bit DMA. Your chip is quite a
> bit older than mine (RTL8102E seems to be one of the older, if not th=
e
> oldest, PCI-E chipset supported by the driver).
>
> Francois, do you know if that's the case, or do you have any active
> contacts at Realtek who can say?
>
> In the meantime, I don't object to reverting the patch for now unless
> we get this sorted out quickly..

=46rancois, ping? Is there anyone else that has access to this kind of
information about these chips?

It's kind of interesting that there's only been one report of this
though. Either the affected chips are rare among people testing
2.6.34-rc or there's something more to this. Maybe something
wierd/unusual about J=F6rn's system?

J=F6rn, are any other devices on your system working with 64-bit
addressing? Try doing this:

find /sys -name "*dma_mask_bits*" | xargs cat

Does anything show more than 32?
