From: "Sohan Shetty" <sshetty@nextpointnetworks.com>
Subject: interface based conntrack entry
Date: Mon, 17 Mar 2008 16:13:45 -0400
Message-ID: <1C6541574A2FC447B53A6B4522B678AF015A12C5@moe.nextone.local>
References: <CAC6870A2B8FE846AD24D7E75B05F90A3F1960@moe.nextone.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Paritosh Tyagi" <ptyagi@nextpointnetworks.com>
To: "Netfilter Developer Mailing List" <netfilter-devel@vger.kernel.org>,
	<netdev@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <CAC6870A2B8FE846AD24D7E75B05F90A3F1960@moe.nextone.local>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46orwarding query from Paritosh Tyagi to Netfilter mailing list.


--------------------------------------------------------------------
Hello,

We are using 2.6.18 version of the kernel and we have following issue r=
elated to conntrack module and Vlan interfaces.



=A0=A0=A0=A0=A0 Ep1 (192.168.1.100)=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0 Eth1.100 =A0(192.168.1.1)=A0=A0=A0 (ip interface) 16=
9.254.16.1
=A0=A0=A0=A0=A0=A0 |-------------------------------------------|-------=
------------------------|

=A0=A0=A0=A0=A0 Ep2 (192.168.1.100)=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0Eth1.101 =A0(192.168.1.1)=A0=A0=A0=A0(ip interface=
) 169.254.16.2
=A0=A0=A0=A0=A0=A0 |-------------------------------------------|-------=
------------------------|


=A0=A0=A0=A0=A0 Here, our box is connected to two distinct networks 192=
=2E168.1/24 via a different vlan. Our application is exposing the same =
ip address (192.168.1.1) on both the vlans. On eth1.100 internal ip add=
ress 169.254.16.1 =A0is configured and on eth1.101 internal ip address =
169.254.16.2 is configured.=20
=A0=A0=A0=A0 Ep1 and ep2 talk to 192.168.1.1 on the two vlans.
=A0=A0=A0=A0 Iptables and arptables rules are added to map incoming/out=
going ip/arp packets on eth1.100 to/from 169.254.16.1 and on eth1.101 t=
o/from 169.254.16.2.=20
=A0
=A0=A0=A0 The problem we are seeing is, that when an incoming packet co=
mes in from ep1 a conntrack entry is created for=20
Proto=3Dudp, srcip=3D192.168.1.100, dstip=3D192.168.1.1, sport=3D5060, =
dport=3D5060, this packet is DNAT'ed to 169.254.16.1 =A0and our applica=
tion receives it on the socket bound to that ip. However, when ep2 send=
s a packet, it seems that the conntrack entry matches it and the ip tab=
le NAT rule (which should map this packet to 169.254.16.2) is ignored a=
nd because of the 4-tuple match with existing udp conntrack entry, the =
packet is sent to 169.254.16.1.=20

=A0 =A0Is there a patch to support the in-interface and out-interface o=
r mark in the conntrack module? So, we can have two entries in there wh=
ere the 4 tuple is the same only the interface is different?=20
=A0=A0=A0=20
-paritosh

=A0=A0=A0=A0=20




--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
