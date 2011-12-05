From: Thomas De Schampheleire <patrickdepinguin@gmail.com>
Subject: Re: [Bonding-devel] ethernet bonding + VLAN: additional VLAN tag in tcpdump
Date: Mon, 5 Dec 2011 10:50:27 +0100
Message-ID: <CAAXf6LXOEpDNf-abqZ_FCJ4G85s-domOHLzH0ur+F77gOvO8EA@mail.gmail.com>
References: <CAAXf6LXiONe5Kb8tdQbQs3SWg8cc6SK_md7-vOV8qN4vYmL8qw@mail.gmail.com>
	<4ED541F4.4080601@gmail.com>
	<20111130075237.GA2109@minipsycho>
	<CAAXf6LXDYmjaQK6g0q6vZLeDCH1yb5MT03c21Ehqv6TgUB_R3w@mail.gmail.com>
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
Received: from mail-vx0-f174.google.com ([209.85.220.174]:62259 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754250Ab1LEJu2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2011 04:50:28 -0500
Received: by vcbfk14 with SMTP id fk14so3755222vcb.19
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2011 01:50:27 -0800 (PST)
In-Reply-To: <CAAXf6LXDYmjaQK6g0q6vZLeDCH1yb5MT03c21Ehqv6TgUB_R3w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Nov 30, 2011 at 10:06 AM, Thomas De Schampheleire
<patrickdepinguin@gmail.com> wrote:
> On Wed, Nov 30, 2011 at 8:52 AM, Jiri Pirko <jpirko@redhat.com> wrote=
:
>> Tue, Nov 29, 2011 at 09:35:00PM CET, nicolas.2p.debian@gmail.com wro=
te:
>>>Le 29/11/2011 14:38, Thomas De Schampheleire a =E9crit :
>>>>Hi,
>>>>
>>>>I'm seeing incorrect tcpdump output in the following scenario:
>>>>
>>>>* ethernet bonding enabled in the kernel, and a single network
>>>>interface (eth0) added as slave
>>>>* bonding mode was set to broadcast, but I don't think this matters
>>>>* VLAN added to the bond0 network interface
>>>>* ip address set on the vlan interface (bond0.1234)
>>>>* tcpdump capturing full packets (-xx or even -x) on the eth0 inter=
face
>>>>
>>>>Then, when pinging from another machine to this ip address, the pin=
g
>>>>reply packets shown by tcpdump incorrectly have a double VLAN tag.
>>>>However, what really appears on the wire is correct: a single VLAN
>>>>tag.
>>>
>>>Copied netdev, because bonding and vlan developers are there.
>>>
>>>Jiri, don't you think this might be related to the work you have don=
e
>>>to make non-hw-accel rx path similar to hw-accel?
>>
>> I do not think so. The changes you are reffering to are unrelated to=
 tx
>> path (where this issue has most probably roots in)
>>
>>>
>>> =A0 =A0 =A0 Nicolas.
>>>
>>>>
>>>>Here is the output from tcpdump:
>>>># /tmp/tcpdump =A0-i eth0 -xx
>>
>> What hw is this?
>
> This is on a Freescale P4080 DPA mac (fsl,p4080-fman-1g-mac).
>
>>
>>>>tcpdump: verbose output suppressed, use -v or -vv for full protocol=
 decode
>>>>listening on eth0, link-type EN10MB (Ethernet), capture size 65535 =
bytes
>>>>01:04:04.607880 IP 192.168.1.2> =A0192.168.1.1: ICMP echo request, =
id 26933, seq 4
>>>>16, length 64
>>>> =A0 =A0 =A0 =A0 0x0000: =A00600 0000 0020 0600 0000 0020 8100 0ffe
>>>> =A0 =A0 =A0 =A0 0x0010: =A00800 4500 0054 0000 4000 4001 b755 c0a8
>>>> =A0 =A0 =A0 =A0 0x0020: =A00102 c0a8 0101 0800 98d7 6935 01a0 e528
>>>> =A0 =A0 =A0 =A0 0x0030: =A00f2a 0000 0000 0000 0000 0000 0000 0000
>>>> =A0 =A0 =A0 =A0 0x0040: =A00000 0000 0000 0000 0000 0000 0000 0000
>>>> =A0 =A0 =A0 =A0 0x0050: =A00000 0000 0000 0000 0000 0000 0000 0000
>>>> =A0 =A0 =A0 =A0 0x0060: =A00000 0000 0000
>>>>01:04:04.607889 IP 192.168.1.1> =A0192.168.1.2: ICMP echo reply, id=
 26933, seq 416
>>>>, length 64
>>>> =A0 =A0 =A0 =A0 0x0000: =A00600 0000 0020 0600 0000 0020 8100 0ffe
>>>> =A0 =A0 =A0 =A0 0x0010: =A08100 0ffe 0800 4500 0054 cc07 0000 4001=
<--------
>>>>extra VLAN header at 0x10
>>>> =A0 =A0 =A0 =A0 0x0020: =A02b4e c0a8 0101 c0a8 0102 0000 a0d7 6935
>>>> =A0 =A0 =A0 =A0 0x0030: =A001a0 e528 0f2a 0000 0000 0000 0000 0000
>>>> =A0 =A0 =A0 =A0 0x0040: =A00000 0000 0000 0000 0000 0000 0000 0000
>>>> =A0 =A0 =A0 =A0 0x0050: =A00000 0000 0000 0000 0000 0000 0000 0000
>>>> =A0 =A0 =A0 =A0 0x0060: =A00000 0000 0000 0000 0000
>>>>
>>>>
>>>>Initial debugging showed that the addition of the extra VLAN header
>>>>takes place in function pcap_read_linux_mmap() of libpcap, in the
>>>>following snippet:
>>>>
>>>>#ifdef HAVE_TPACKET2
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (handle->md.tp_version =3D=3D T=
PACKET_V2&& =A0h.h2->tp_vlan_tci&&
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp_snaplen>=3D 2 * ETH_ALE=
N) {
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct vlan_tag *t=
ag;
>>>>
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bp -=3D VLAN_TAG_L=
EN;
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memmove(bp, bp + V=
LAN_TAG_LEN, 2 * ETH_ALEN);
>>>>
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tag =3D (struct vl=
an_tag *)(bp + 2 * ETH_ALEN);
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tag->vlan_tpid =3D=
 htons(ETH_P_8021Q);
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tag->vlan_tci =3D =
htons(h.h2->tp_vlan_tci);
>>>>
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pcaphdr.caplen +=3D=
 VLAN_TAG_LEN;
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pcaphdr.len +=3D V=
LAN_TAG_LEN;
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>>>#endif
>>
>> I haven't look into this code yet, but where's the code which does t=
he
>> first header inclusion?
>
> I would assume this is done by the VLAN layer. This is a ping reply
> originating from the icmp code, passing down to the vlan layer, then
> to the ethernet bonding layer, and then to the hardware. But before
> this is passed to hardware, libpcap captures the packet.
>
> I haven't debugged that part, though, so I can't give you a direct
> pointer to the code that does it.
>
>>
>>
>>>>
>>>>Upon entry of this code, the packet in bp already contains a VLAN h=
eader.
>>>>
>>>>It's unclear to me where the problem lies exactly. I suspect it has
>>>>something to do with the ethernet bonding layer indicating it has
>>>>hardware vlan tagging support, while it does already fill in the vl=
an
>>>>header, and libpcap being confused by this.
>>>>
>>>>As mentioned previously, the packets on the wire are correct, and t=
his
>>>>is purely a capturing problem.
>>>>
>

Does anyone have an idea on how this is supposed to work and why the
extra header gets inserted?

Thanks,
Thomas
