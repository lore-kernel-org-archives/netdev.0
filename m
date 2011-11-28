From: Vincent Blut <vincent.debian@free.fr>
Subject: Re: sky2: hw csum failure
Date: Mon, 28 Nov 2011 19:20:45 +0000
Message-ID: <4ED3DF0D.8030904@free.fr>
References: <4ED37A2C.5040608@free.fr> <20111128085030.248ebcb7@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Debian Bug Tracking System <609994@bugs.debian.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:42510 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751795Ab1K1SUX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Nov 2011 13:20:23 -0500
In-Reply-To: <20111128085030.248ebcb7@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 28/11/2011 16:50, Stephen Hemminger a =C3=A9crit :
> On Mon, 28 Nov 2011 12:10:20 +0000
> Vincent Blut <vincent.debian@free.fr> wrote:
>
>  =20
>> Hi,
>>
>> [reference: http://bugs.debian.org/609994]
>>
>> I have a Marvell ethernet controller which presents some failures wh=
en
>> 'rx checksumming' is enabled,
>> here is the model:
>>
>> $ lspci -vvs 03:00.0
>> 03:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8053 P=
CI-E
>> Gigabit Ethernet Controller (rev 15)
>>         Subsystem: Micro-Star International Co., Ltd. Marvell 88E805=
3
>> Gigabit Ethernet Controller (MSI)
>>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
>> ParErr- Stepping- SERR- FastB2B- DisINTx+
>>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAb=
ort-
>> <TAbort- <MAbort- >SERR- <PERR- INTx-
>>         Latency: 0, Cache Line Size: 32 bytes
>>         Interrupt: pin A routed to IRQ 44
>>         Region 0: Memory at fdbfc000 (64-bit, non-prefetchable) [siz=
e=3D16K]
>>         Region 2: I/O ports at 7c00 [size=3D256]
>>         [virtual] Expansion ROM at fda00000 [disabled] [size=3D128K]
>>         Capabilities: <access denied>
>>         Kernel driver in use: sky2
>>
>> At first I thought it was due to the MTU size, so I tested different
>> values but unfortunately without positive effect.
>> Overall this issue appears randomly when the incoming traffic is hig=
h. I
>> tested 2.6.32, 3.1.1, and 3.2-rc3, sadly
>> all are affected. Finally, the only way to avoid those failures is t=
o
>> disabled 'rx checksumming' (ethtool -K ethX rx off).
>>
>> Here is the stack trace:
>>
>> [   14.615648] sky2 0000:03:00.0: eth1: enabling interface
>> [   14.616452] ADDRCONF(NETDEV_UP): eth1: link is not ready
>> [   17.094194] sky2 0000:03:00.0: eth1: Link is up at 1000 Mbps, ful=
l
>> duplex, flow control both
>> [   17.094887] ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
>> [   28.080018] eth1: no IPv6 routers present
>> [  563.816032] sky2 0000:03:00.0: eth1: hung mac 124:22 fifo 195 (15=
0:145)
>> [  563.816036] sky2 0000:03:00.0: eth1: receiver hang detected
>> [  567.005422] sky2 0000:03:00.0: eth1: Link is up at 1000 Mbps, ful=
l
>> duplex, flow control both
>> [ 1040.816314] sky2 0000:03:00.0: eth1: rx error, status 0x7ffc0001
>> length 1004
>> [ 2097.401616] sky2 0000:03:00.0: eth1: rx error, status 0x39a339a3 =
length 0
>>    =20
> This isn't really a hardware checksum failure.
> Your problem is deeper than that. The internal parts of the chip are =
not
> communicating correctly. The "hung mac" is a problem only occurs if t=
he PCI
> is really stuck. There may be a timing issue on your motherboard, or =
the BIOS
> isn't setting up the device properly. The timing then gets messed up =
between
> the end of frame status and the PCI shared memory region. Turning che=
cksum
> off masks the problem, but the status is probably still corrupt.
>
>  =20

IMO, turning checksum off does more than masking the problem because it
prevents the
connection to stop working or even freeze the system.

> In either case the problem is beyond the ability of the driver to fix=
 or workaround.
> Your best bet is to see if there is a BIOS update, or replace the har=
dware.
>  =20

Sadly the last BIOS update was in 2006, so I don't think I can rely on
the manufacturer.
But again, deactivate the capability of checksum by NIC hardware makes
the interface stable since March.

Regards,
Vincent
