From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: Re: [PATCH 4/5] ieee802154: add documentation about our stack
Date: Fri, 5 Jun 2009 17:40:45 +0400
Message-ID: <bc64b4640906050640n77bddf37u8e549dff72508c2d@mail.gmail.com>
References: <1244168990-28355-1-git-send-email-dbaryshkov@gmail.com>
	 <1244168990-28355-2-git-send-email-dbaryshkov@gmail.com>
	 <1244168990-28355-3-git-send-email-dbaryshkov@gmail.com>
	 <1244168990-28355-4-git-send-email-dbaryshkov@gmail.com>
	 <1244168990-28355-5-git-send-email-dbaryshkov@gmail.com>
	 <1244207921.23850.17.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, slapin@ossfans.org,
	davem@davemloft.net, Stephen Rothwell <sfr@canb.auug.org.au>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f213.google.com ([209.85.220.213]:55161 "EHLO
	mail-fx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755121AbZFENkq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2009 09:40:46 -0400
In-Reply-To: <1244207921.23850.17.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/6/5 Marcel Holtmann <marcel@holtmann.org>:
> Hi Dmitry,
>
>> Add MAINTAINERS entry and a small text describing our stack interfac=
es,
>> how to hook the drivers, etc.
>>
>> Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
>> Signed-off-by: Sergey Lapin <slapin@ossfans.org>
>> ---
>> =A0Documentation/networking/ieee802154.txt | =A0 76 ++++++++++++++++=
+++++++++++++++
>> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 | =A0 12 +++++
>> =A02 files changed, 88 insertions(+), 0 deletions(-)
>> =A0create mode 100644 Documentation/networking/ieee802154.txt
>>
>> diff --git a/Documentation/networking/ieee802154.txt b/Documentation=
/networking/ieee802154.txt
>> new file mode 100644
>> index 0000000..a0280ad
>> --- /dev/null
>> +++ b/Documentation/networking/ieee802154.txt
>> @@ -0,0 +1,76 @@
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 Linux IEEE 802.15.4 implementation
>> +
>> +
>> +Introduction
>> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> +
>> +The Linux-ZigBee project goal is to provide complete implementation
>> +of IEEE 802.15.4 / ZigBee / 6LoWPAN protocols. IEEE 802.15.4 is a s=
tack
>> +of protocols for organizing Low-Rate Wireless Personal Area Network=
s.
>> +
>> +Currently only IEEE 802.15.4 layer is implemented. We have choosen
>> +to use plain Berkeley socket API, the generic Linux networking stac=
k
>> +to transfer IEEE 802.15.4 messages and a special protocol over gene=
tlink
>> +for configuration/management
>> +
>> +
>> +Socket API
>> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> +
>> +int sd =3D socket(PF_IEEE802154, SOCK_DGRAM, 0);
>> +.....
>> +
>> +The address family, socket addresses etc. are defined in the
>> +include/net/ieee802154/af_ieee802154.h header or in the special hea=
der
>> +in our userspace package (see either linux-zigbee sourceforge downl=
oad page
>> +or git tree at git://linux-zigbee.git.sourceforge.net/gitroot/linux=
-zigbee).
>> +
>> +One can use SOCK_RAW for passing raw data towards device xmit funct=
ion. YMMV.
>> +
>> +
>> +MLME - MAC Level Management
>> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
>> +
>> +Most of IEEE 802.15.4 MLME interfaces are directly mapped on netlin=
k commands.
>> +See the include/net/ieee802154/nl802154.h header. Our userspace too=
ls package
>> +(see above) provides CLI configuration utility for radio interfaces=
 and simple
>> +coordinator for IEEE 802.15.4 networks as an example users of MLME =
protocol.
>> +
>> +
>> +Kernel side
>> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> +
>> +Like with WiFi, there are several types of devices implementing IEE=
E 802.15.4.
>> +1) 'HardMAC'. The MAC layer is implemented in the device itself, th=
e device
>> + =A0 exports MLME and data API.
>> +2) 'SoftMAC' or just radio. These types of devices are just radio t=
ransceivers
>> + =A0 possibly with some kinds of acceleration like automatic CRC co=
mputation and
>> + =A0 comparation, automagic ACK handling, address matching, etc.
>> +
>> +Those types of devices require different approach to be hooked into=
 Linux kernel.
>> +
>> +
>> +HardMAC
>> +=3D=3D=3D=3D=3D=3D=3D
>> +
>> +See the header include/net/ieee802154/netdevice.h. You have to impl=
ement Linux
>> +net_device, with .type =3D ARPHRD_IEEE802154. Data is exchanged wit=
h socket family
>> +code via plain sk_buffs. The control block of sk_buffs will contain=
 additional
>> +info as described in the struct ieee802154_mac_cb.
>
> are you sending IP packets over this ARPHRD_IEEE802154 network device=
s
> or are you just abusing it as a control interface. If it is the later
> then can we please stop doing this. I really dislike these irda0,
> wmaster0 and alike stuff. If you can't configure it as real IP device=
,
> you should not use struct net_device at all from my point of view. Fo=
r
> all your control details you have netlink so no need for an extra dev=
ice
> here unless it can actually talk IP (or similar like IPX etc.).

Hmm. Once I've thought about it, as net_device seemed a Really Big Thin=
g to me
to be used for our stack. However from the beginning we wanted to use p=
lain BSD
sockets API, we wanted to use sk_buffs (of course) for the whole
message interface.
And when prototyping lowpan_device, I ended duplicating lots of net_dev=
ice
functionality on my own.
Either we have to develop some lightweight "net_device" abstracted from=
 IP & Ko,
but containing sk_buff queues, header ops, etc, or end up with function=
ality
duplication and hacks like in bluetooth (where skb->dev is used to stor=
e hci_dev
instead of net_device).

Hmm. AX.25, AppleTalk, CAN, DecNet, most of other procotols sitting ins=
ide
Linux kernel do use net_device structure, why should we differ?

Moreover, once we implement 6lowpan support (an encapsulation for IPv6 =
frames
into IEEE 802.15.4 ones) it will be possible to send IPv6 frames direct=
ly over
IEEE 802.15.4.

--=20
With best wishes
Dmitry
