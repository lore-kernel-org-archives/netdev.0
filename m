From: Thomas De Schampheleire <patrickdepinguin@gmail.com>
Subject: Re: [Bonding-devel] ethernet bonding + VLAN: additional VLAN tag in tcpdump
Date: Fri, 16 Dec 2011 07:47:06 +0100
Message-ID: <CAAXf6LVo1_L17-cnoJfX0uDyOsAu3Bi9E79vqj8eRNbHUXh9jg@mail.gmail.com>
References: <CAAXf6LXiONe5Kb8tdQbQs3SWg8cc6SK_md7-vOV8qN4vYmL8qw@mail.gmail.com>
	<4ED541F4.4080601@gmail.com>
	<20111130075237.GA2109@minipsycho>
	<CAAXf6LXDYmjaQK6g0q6vZLeDCH1yb5MT03c21Ehqv6TgUB_R3w@mail.gmail.com>
	<CAAXf6LXOEpDNf-abqZ_FCJ4G85s-domOHLzH0ur+F77gOvO8EA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>, bonding-devel@lists.sourceforge.net,
	tcpdump-workers@lists.tcpdump.org,
	Ronny Meeus <ronny.meeus@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:44832 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985Ab1LPGrH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 01:47:07 -0500
Received: by vcbfk14 with SMTP id fk14so2215194vcb.19
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2011 22:47:06 -0800 (PST)
In-Reply-To: <CAAXf6LXOEpDNf-abqZ_FCJ4G85s-domOHLzH0ur+F77gOvO8EA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 5, 2011 at 10:50 AM, Thomas De Schampheleire
<patrickdepinguin@gmail.com> wrote:
> Hi,
>
> On Wed, Nov 30, 2011 at 10:06 AM, Thomas De Schampheleire
> <patrickdepinguin@gmail.com> wrote:
>> On Wed, Nov 30, 2011 at 8:52 AM, Jiri Pirko <jpirko@redhat.com> wrot=
e:
>>> Tue, Nov 29, 2011 at 09:35:00PM CET, nicolas.2p.debian@gmail.com wr=
ote:
>>>>Le 29/11/2011 14:38, Thomas De Schampheleire a =E9crit :
>>>>>Hi,
>>>>>
>>>>>I'm seeing incorrect tcpdump output in the following scenario:
>>>>>
>>>>>* ethernet bonding enabled in the kernel, and a single network
>>>>>interface (eth0) added as slave
>>>>>* bonding mode was set to broadcast, but I don't think this matter=
s
>>>>>* VLAN added to the bond0 network interface
>>>>>* ip address set on the vlan interface (bond0.1234)
>>>>>* tcpdump capturing full packets (-xx or even -x) on the eth0 inte=
rface
>>>>>
>>>>>Then, when pinging from another machine to this ip address, the pi=
ng
>>>>>reply packets shown by tcpdump incorrectly have a double VLAN tag.
>>>>>However, what really appears on the wire is correct: a single VLAN
>>>>>tag.
>>>>
>>>>Copied netdev, because bonding and vlan developers are there.
>>>>
>>>>Jiri, don't you think this might be related to the work you have do=
ne
>>>>to make non-hw-accel rx path similar to hw-accel?
>>>
>>> I do not think so. The changes you are reffering to are unrelated t=
o tx
>>> path (where this issue has most probably roots in)
>>>
>>>>
>>>> =A0 =A0 =A0 Nicolas.
>>>>
>>>>>
>>>>>Here is the output from tcpdump:
>>>>># /tmp/tcpdump =A0-i eth0 -xx
>>>
>>> What hw is this?
>>
>> This is on a Freescale P4080 DPA mac (fsl,p4080-fman-1g-mac).
>>
>>>
>>>>>tcpdump: verbose output suppressed, use -v or -vv for full protoco=
l decode
>>>>>listening on eth0, link-type EN10MB (Ethernet), capture size 65535=
 bytes
>>>>>01:04:04.607880 IP 192.168.1.2> =A0192.168.1.1: ICMP echo request,=
 id 26933, seq 4
>>>>>16, length 64
>>>>> =A0 =A0 =A0 =A0 0x0000: =A00600 0000 0020 0600 0000 0020 8100 0ff=
e
>>>>> =A0 =A0 =A0 =A0 0x0010: =A00800 4500 0054 0000 4000 4001 b755 c0a=
8
>>>>> =A0 =A0 =A0 =A0 0x0020: =A00102 c0a8 0101 0800 98d7 6935 01a0 e52=
8
>>>>> =A0 =A0 =A0 =A0 0x0030: =A00f2a 0000 0000 0000 0000 0000 0000 000=
0
>>>>> =A0 =A0 =A0 =A0 0x0040: =A00000 0000 0000 0000 0000 0000 0000 000=
0
>>>>> =A0 =A0 =A0 =A0 0x0050: =A00000 0000 0000 0000 0000 0000 0000 000=
0
>>>>> =A0 =A0 =A0 =A0 0x0060: =A00000 0000 0000
>>>>>01:04:04.607889 IP 192.168.1.1> =A0192.168.1.2: ICMP echo reply, i=
d 26933, seq 416
>>>>>, length 64
>>>>> =A0 =A0 =A0 =A0 0x0000: =A00600 0000 0020 0600 0000 0020 8100 0ff=
e
>>>>> =A0 =A0 =A0 =A0 0x0010: =A08100 0ffe 0800 4500 0054 cc07 0000 400=
1<--------
>>>>>extra VLAN header at 0x10
>>>>> =A0 =A0 =A0 =A0 0x0020: =A02b4e c0a8 0101 c0a8 0102 0000 a0d7 693=
5
>>>>> =A0 =A0 =A0 =A0 0x0030: =A001a0 e528 0f2a 0000 0000 0000 0000 000=
0
>>>>> =A0 =A0 =A0 =A0 0x0040: =A00000 0000 0000 0000 0000 0000 0000 000=
0
>>>>> =A0 =A0 =A0 =A0 0x0050: =A00000 0000 0000 0000 0000 0000 0000 000=
0
>>>>> =A0 =A0 =A0 =A0 0x0060: =A00000 0000 0000 0000 0000
>>>>>
>>>>>
>>>>>Initial debugging showed that the addition of the extra VLAN heade=
r
>>>>>takes place in function pcap_read_linux_mmap() of libpcap, in the
>>>>>following snippet:
>>>>>
>>>>>#ifdef HAVE_TPACKET2
>>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (handle->md.tp_version =3D=3D =
TPACKET_V2&& =A0h.h2->tp_vlan_tci&&
>>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp_snaplen>=3D 2 * ETH_AL=
EN) {
>>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct vlan_tag *=
tag;
>>>>>
>>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bp -=3D VLAN_TAG_=
LEN;
>>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memmove(bp, bp + =
VLAN_TAG_LEN, 2 * ETH_ALEN);
>>>>>
>>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tag =3D (struct v=
lan_tag *)(bp + 2 * ETH_ALEN);
>>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tag->vlan_tpid =3D=
 htons(ETH_P_8021Q);
>>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tag->vlan_tci =3D=
 htons(h.h2->tp_vlan_tci);
>>>>>
>>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pcaphdr.caplen +=3D=
 VLAN_TAG_LEN;
>>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pcaphdr.len +=3D =
VLAN_TAG_LEN;
>>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>>>>#endif
>>>
>>> I haven't look into this code yet, but where's the code which does =
the
>>> first header inclusion?
>>
>> I would assume this is done by the VLAN layer. This is a ping reply
>> originating from the icmp code, passing down to the vlan layer, then
>> to the ethernet bonding layer, and then to the hardware. But before
>> this is passed to hardware, libpcap captures the packet.
>>
>> I haven't debugged that part, though, so I can't give you a direct
>> pointer to the code that does it.
>>
>>>
>>>
>>>>>
>>>>>Upon entry of this code, the packet in bp already contains a VLAN =
header.
>>>>>
>>>>>It's unclear to me where the problem lies exactly. I suspect it ha=
s
>>>>>something to do with the ethernet bonding layer indicating it has
>>>>>hardware vlan tagging support, while it does already fill in the v=
lan
>>>>>header, and libpcap being confused by this.
>>>>>
>>>>>As mentioned previously, the packets on the wire are correct, and =
this
>>>>>is purely a capturing problem.
>>>>>
>>
>
> Does anyone have an idea on how this is supposed to work and why the
> extra header gets inserted?

Bump.
I would expect that this problem is independent on the hardware, and
therefore should be reproducible by others as well, pretty easily.

Thanks,
Thomas
