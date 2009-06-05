From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 4/5] ieee802154: add documentation about our stack
Date: Fri, 5 Jun 2009 20:00:06 +0400
Message-ID: <bc64b4640906050900y233aecd3j24dddb4fd9d2820@mail.gmail.com>
References: <1244168990-28355-1-git-send-email-dbaryshkov@gmail.com>
	 <1244168990-28355-2-git-send-email-dbaryshkov@gmail.com>
	 <1244168990-28355-3-git-send-email-dbaryshkov@gmail.com>
	 <1244168990-28355-4-git-send-email-dbaryshkov@gmail.com>
	 <1244168990-28355-5-git-send-email-dbaryshkov@gmail.com>
	 <1244207921.23850.17.camel@localhost.localdomain>
	 <bc64b4640906050640n77bddf37u8e549dff72508c2d@mail.gmail.com>
	 <1244211945.23850.53.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1244211945.23850.53.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2009/6/5 Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>:
> Hi Dmitry,
>
>> >> Add MAINTAINERS entry and a small text describing our stack inter=
faces,
>> >> how to hook the drivers, etc.
>> >>
>> >> Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> >> Signed-off-by: Sergey Lapin <slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org>
>> >> ---
>> >> =A0Documentation/networking/ieee802154.txt | =A0 76 +++++++++++++=
++++++++++++++++++
>> >> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 | =A0 12 +++++
>> >> =A02 files changed, 88 insertions(+), 0 deletions(-)
>> >> =A0create mode 100644 Documentation/networking/ieee802154.txt
>> >>
>> >> diff --git a/Documentation/networking/ieee802154.txt b/Documentat=
ion/networking/ieee802154.txt
>> >> new file mode 100644
>> >> index 0000000..a0280ad
>> >> --- /dev/null
>> >> +++ b/Documentation/networking/ieee802154.txt
>> >> @@ -0,0 +1,76 @@
>> >> +
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 Linux IEEE 802.15.4 implementation
>> >> +
>> >> +
>> >> +Introduction
>> >> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> >> +
>> >> +The Linux-ZigBee project goal is to provide complete implementat=
ion
>> >> +of IEEE 802.15.4 / ZigBee / 6LoWPAN protocols. IEEE 802.15.4 is =
a stack
>> >> +of protocols for organizing Low-Rate Wireless Personal Area Netw=
orks.
>> >> +
>> >> +Currently only IEEE 802.15.4 layer is implemented. We have choos=
en
>> >> +to use plain Berkeley socket API, the generic Linux networking s=
tack
>> >> +to transfer IEEE 802.15.4 messages and a special protocol over g=
enetlink
>> >> +for configuration/management
>> >> +
>> >> +
>> >> +Socket API
>> >> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> >> +
>> >> +int sd =3D socket(PF_IEEE802154, SOCK_DGRAM, 0);
>> >> +.....
>> >> +
>> >> +The address family, socket addresses etc. are defined in the
>> >> +include/net/ieee802154/af_ieee802154.h header or in the special =
header
>> >> +in our userspace package (see either linux-zigbee sourceforge do=
wnload page
>> >> +or git tree at git://linux-zigbee.git.sourceforge.net/gitroot/li=
nux-zigbee).
>> >> +
>> >> +One can use SOCK_RAW for passing raw data towards device xmit fu=
nction. YMMV.
>> >> +
>> >> +
>> >> +MLME - MAC Level Management
>> >> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
>> >> +
>> >> +Most of IEEE 802.15.4 MLME interfaces are directly mapped on net=
link commands.
>> >> +See the include/net/ieee802154/nl802154.h header. Our userspace =
tools package
>> >> +(see above) provides CLI configuration utility for radio interfa=
ces and simple
>> >> +coordinator for IEEE 802.15.4 networks as an example users of ML=
ME protocol.
>> >> +
>> >> +
>> >> +Kernel side
>> >> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> >> +
>> >> +Like with WiFi, there are several types of devices implementing =
IEEE 802.15.4.
>> >> +1) 'HardMAC'. The MAC layer is implemented in the device itself,=
 the device
>> >> + =A0 exports MLME and data API.
>> >> +2) 'SoftMAC' or just radio. These types of devices are just radi=
o transceivers
>> >> + =A0 possibly with some kinds of acceleration like automatic CRC=
 computation and
>> >> + =A0 comparation, automagic ACK handling, address matching, etc.
>> >> +
>> >> +Those types of devices require different approach to be hooked i=
nto Linux kernel.
>> >> +
>> >> +
>> >> +HardMAC
>> >> +=3D=3D=3D=3D=3D=3D=3D
>> >> +
>> >> +See the header include/net/ieee802154/netdevice.h. You have to i=
mplement Linux
>> >> +net_device, with .type =3D ARPHRD_IEEE802154. Data is exchanged =
with socket family
>> >> +code via plain sk_buffs. The control block of sk_buffs will cont=
ain additional
>> >> +info as described in the struct ieee802154_mac_cb.
>> >
>> > are you sending IP packets over this ARPHRD_IEEE802154 network dev=
ices
>> > or are you just abusing it as a control interface. If it is the la=
ter
>> > then can we please stop doing this. I really dislike these irda0,
>> > wmaster0 and alike stuff. If you can't configure it as real IP dev=
ice,
>> > you should not use struct net_device at all from my point of view.=
 For
>> > all your control details you have netlink so no need for an extra =
device
>> > here unless it can actually talk IP (or similar like IPX etc.).
>>
>> Hmm. Once I've thought about it, as net_device seemed a Really Big T=
hing to me
>> to be used for our stack. However from the beginning we wanted to us=
e plain BSD
>> sockets API, we wanted to use sk_buffs (of course) for the whole
>> message interface.
>> And when prototyping lowpan_device, I ended duplicating lots of net_=
device
>> functionality on my own.
>> Either we have to develop some lightweight "net_device" abstracted f=
rom IP & Ko,
>> but containing sk_buff queues, header ops, etc, or end up with funct=
ionality
>> duplication and hacks like in bluetooth (where skb->dev is used to s=
tore hci_dev
>> instead of net_device).
>
> that skb->dev pointer is typed as net_device is just a cosmetic detai=
l
> from my point of view. And having Bluetooth use it as hci_dev is not
> actually a hack. We just can't send Bluetooth HCI skb directly to the=
 IP
> layer, but we also don't do that ;)
>
>> Hmm. AX.25, AppleTalk, CAN, DecNet, most of other procotols sitting =
inside
>> Linux kernel do use net_device structure, why should we differ?
>
> Don't know about CAN since I never looked deep enough into it. Howeve=
r
> for the other, they do transport some sort of networking packets over
> it. So my point is as long as I can use ifconfig of ip to set an addr=
ess
> on these interfaces and route them it makes sense to. Just to reuse
> net_device because it is convenient for a control interface sounds wr=
ong
> to me. The IrDA stuff is one big example of this.

Hmm. Let's make things clear: do you request for ip/ifconfig to be work=
ing
 upon a net_device or do you request that network packets are transmitt=
ed
over the net_device?

>> Moreover, once we implement 6lowpan support (an encapsulation for IP=
v6 frames
>> into IEEE 802.15.4 ones) it will be possible to send IPv6 frames dir=
ectly over
>> IEEE 802.15.4.
>
> So using the socket interfaces has nothing do with the net_device you
> are creating. So that argument doesn't work for me. Even mac80211
> nowadays uses a proper hardware abstraction (ieee80211_hw and
> ieee80211_ops) and you should do the same.

We have more or less the same abstraction for the simple radios (if you=
'd like,
please check the serie at the branch for-review-v2, or the serie that w=
as posted
several days ago. Basically simple radio provide interface for packet r=
x/tx,
energy detection, etc. Then mac802154 (mac80211 analogy) comes into pla=
y:
all radio packets, queue processing, etc. are guided by master interfac=
e, which
multiplexes packets  from/to one or several ARPHRD_IEEE802154 interface=
s.
Those interfaces then decode if the packet is beacon, command or data f=
rame,
passes data frames to socket family, calls netlink callbacks for comman=
ds, etc.

While I understand that master interface can be dropped/replaced by
non-net_device thing, I think that logical interfaces should be provide=
d
via net_device. Please correct me if I'm wrong here.

=46or HardMAC (that part that is presented in this patchseri) we've cut
this scheme
directly at ARPHRD_IEEE802154 device. The device driver on it's own sen=
ds/
receives data frames via hardware and calls MLME callbacks where approp=
riate.

> Once you have actually implemented 6lowpan then these are the ones th=
at
> should use net_device and show up within ifconfig.

--=20
With best wishes
Dmitry
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
