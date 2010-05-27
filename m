From: "Vincent, Pradeep" <pradeepv@amazon.com>
Subject: Re: UDP Fragmentation and DF bit..
Date: Thu, 27 May 2010 14:58:07 -0700
Message-ID: <C82438FF.170E9%pradeepv@amazon.com>
References: <87bpc11xyw.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-4101.amazon.com ([72.21.198.25]:29628 "EHLO
	smtp-fw-4101.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932971Ab0E0V6W convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 17:58:22 -0400
In-Reply-To: <87bpc11xyw.fsf@basil.nowhere.org>
Content-Language: en
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Andi.

> I don't understand your mtu-small/big concept. PMTU is per IP and per
> flow. So there's only always a single PMTU, not small and big.

Example Setup: One part of the network supports MTU-big and another par=
t of
the network supports MTU-small. The NIC interfaces are configured with =
MTU
corresponding to the part of the network they are connected to.

When a host in MTU-big part of the network sends a packet to a host in
MTU-small part of the network, the router bordering these two sections =
of
the network sends ICMP messages to the host in MTU-big section of the
network to enable PMTU discovery.

Everything works great for TCP. UDP's PMTU discovery seems to be availa=
ble
for some datagram sizes ( size < MTU-big) but not otherwise.

>DF=3D1 on fragments would mean the application has to do pmtu discover=
y
> even with fragments for the case when the kernel does not know
> the path mtu yet.

Is there a reason kernel can't learn the PMTU using ICMP messages gener=
ated
due to large size fragments with DF=3D1 ?


>But if the app supports pmtu discovery it's better
> to not use fragments in the first place.

Absolutely.=20

Thanks,

- Pradeep Vincent

On 5/27/10 2:43 AM, "Andi Kleen" <andi@firstfloor.org> wrote:

> "Vincent, Pradeep" <pradeepv@amazon.com> writes:
>=20
>> OMan 7 ip=B9 declares that =B3The  system-wide  default  is  control=
led  by  the
>> ip_no_pmtu_disc  sysctl  for SOCK_STREAM  sockets,  and  disabled  o=
n all
>> others.=B2 which led me to think ODF=B9 bit will not be set for UDP =
packets.
>> But..
>=20
> One should add ip.7 is not really a spec, just documentation
> how things were quite a few years ago. It unfortunately
> does often not get updated when things change.
>=20
>>=20
>> In a network environment where MTU-big and MTU-small co-exist (and h=
ave
>> router=B9s fragmentation turned off in favor of PMTU discovery), UDP=
 packets
>> that are > MTU-small and < MTU-big find the PMTU effectively but UDP
>> packets
>=20
>=20
> I don't understand your mtu-small/big concept. PMTU is per IP and per
> flow. So there's only always a single PMTU, not small and big.
>=20
> Or do you refer to a single IP NAT situation where a single IP
> shares different MTUs?
>=20
>> Is there a reason ODF=B9 bit cannot be set on fragmented packets on =
UDP
>> transmission ? I couldn=B9t find anything in RFC for IP protocol tha=
t
>> prohibited DF bit on fragmented packets. Did I miss
>> something here ?
>=20
>> Would it be reasonable if PMTU discovery is performed (DF bit set +
>> appropriate icmp logic) even for locally fragmented packets ? I thin=
k
>> this
>=20
>=20
> DF=3D1 on fragments would mean the application has to do pmtu discove=
ry
> even with fragments for the case when the kernel does not know
> the path mtu yet. But if the app supports pmtu discovery it's better
> to not use fragments in the first place.
>=20
> -Andi
>=20
> --
> ak@linux.intel.com -- Speaking for myself only.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20

