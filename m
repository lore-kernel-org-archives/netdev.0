From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bridging + load balancing bonding
Date: Fri, 23 Oct 2009 10:55:31 +0200
Message-ID: <4AE16F83.7080400@gmail.com>
References: <20091022122339.GA20148@spaans.fox.local> <4AE07D3C.3040702@gmail.com> <20091023083851.GA18457@spaans.fox.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jasper Spaans <spaans@fox-it.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59357 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbZJWIzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 04:55:31 -0400
In-Reply-To: <20091023083851.GA18457@spaans.fox.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jasper Spaans a =E9crit :
> Hi Eric,
>=20
> On Thu, Oct 22, 2009 at 05:41:48PM +0200, Eric Dumazet wrote:
>=20
>> Very nice setup, and nice finding.
>>
>> Dont locally generated (or outed) packets have h_source set to bond_=
dev->dev_addr anyway ?
>>
>> So your solution might be the right fix...
>>
>> About other ideas... I was thinking of TEE target (not in mainline u=
nfortunatly) :
>>
>> iptables -t mangle -A PREROUTING -i eth0 <some hash on mac addr>  -j=
 TEE --gateway 192.168.99.1  # IDS1
>> iptables -t mangle -A PREROUTING -i eth0 !<some hash on mac addr>  -=
j TEE --gateway 192.168.99.2  # IDS2
>=20
> Unfortunately, this won't work: the TEE target works at IP-level, and
> changes mac-addresses, which is a no-go thing for us.. (and we won't =
be able
> to see non-IP traffic such as ARP on the IDS machines)
>=20

Of course, iptables / TEE works at IP level, so you'll need some ebtabl=
es analogy to work at ethernet level.

Dont you think special attention is needed for multicast/broadcast traf=
ic (they should be sent to both IDS) ?

