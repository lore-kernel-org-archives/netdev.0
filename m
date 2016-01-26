From: Alan Davey <Alan.Davey@metaswitch.com>
Subject: =?Windows-1252?Q?doubt_about_the_behaviour_of_a_Linux_IPv4_raw_socket,_wi?=
 =?Windows-1252?Q?th_the_IP=5FHDRINCL_option_set,_rejecting_a_packet_bigge?=
 =?Windows-1252?Q?r_than_the_outgoing_interface=92s_MTU_size?=
Date: Tue, 26 Jan 2016 17:29:14 +0000
Message-ID: <BN3PR0201MB10592F17F9CC717E46A738B0F9D80@BN3PR0201MB1059.namprd02.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0131.outbound.protection.outlook.com ([207.46.100.131]:12157
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751632AbcAZTEO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2016 14:04:14 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46olks

I have a doubt about the behaviour of a Linux IPv4 raw socket, with the=
 IP_HDRINCL option set, rejecting a packet bigger than the outgoing int=
erface=92s MTU size with EMSGSIZE.=A0 Please take a look at the followi=
ng and let me know if I should make a kernel code change to remove this=
 behaviour and fragment the packet instead.

- raw_send_hdrinc() (net/ipv4/raw.c) has an explicit check for (length =
> rt->dst.dev->mtu), returning -EMSGSIZE if this is true.

- I do not understand the reason for this restriction.=A0 If a packet w=
as received on one interface and routed out through another interface w=
ith a smaller MTU then the packet would be fragmented.=A0 Why is a loca=
lly originated packet treated differently?

- I note that the =93raw(7) - Linux man page=94 lists =93When the IP_HD=
RINCL option is set, datagrams will not be fragmented and are limited t=
o the interface MTU=94 as a known bug.

Please let me know if you have any questions.

Regards
Alan Davey
