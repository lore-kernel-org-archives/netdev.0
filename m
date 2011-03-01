From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH net-2.6] bonding: drop frames received with master's	source
 MAC
Date: Tue, 01 Mar 2011 22:30:52 +0100
Message-ID: <4D6D658C.90300@gmail.com>
References: <1298668408-14849-1-git-send-email-andy@greyhouse.net> <4D68276B.90104@gmail.com> <20110225222455.GI11864@gospo.rdu.redhat.com> <4D683653.4050409@gmail.com> <20110228163255.GJ11864@gospo.rdu.redhat.com> <4D6C1764.1040008@gmail.com> <20110301023525.GK11864@gospo.rdu.redhat.com> <9882.1298958366@death> <20110301181624.GM11864@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Jiri Pirko <jpirko@redhat.com>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:47347 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752996Ab1CAVbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 16:31:32 -0500
Received: by fxm17 with SMTP id 17so5272556fxm.19
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2011 13:31:31 -0800 (PST)
In-Reply-To: <20110301181624.GM11864@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01/03/2011 19:16, Andy Gospodarek a =E9crit :

[snip]

> Knowing that I'm using an unmanaged switch with balance-rr probably
> helps understand how this is happening.  I'll clarify this however, s=
o
> we are all on the same page.
>
> In my situation, eth2 and eth3 are in bond0.  When bond0 transmits th=
e
> NS, let's say it goes out eth3.  Since it is a multicast frame my swi=
tch
> will broadcast this to all ports and eth2 will receive the frame with
> the source MAC address being the same as bond0's MAC address.  This
> frame is passed up the stack to the ipv6 layer and appears to be a
> response to the NS from another host and is dropped.

'sounds perfectly normal.

This problem is described in detail in chapter 5.4.3 and appendix A of =
RFC4862 "IPv6 Stateless=20
Address Autoconfiguration".

As this is clearly IPv6 related, it sounds normal from my point of view=
 to fix it at the=20
ndisc_recv_ns() level.

Quoting the RFC:

   "In those cases where the hardware cannot suppress loopbacks, howeve=
r,
    one possible software heuristic to filter out unwanted loopbacks is
    to discard any received packet whose link-layer source address is t=
he
    same as the receiving interface's.  There is even a link-layer
    specification that requires that any such packets be discarded
    [IEEE802.11].  Unfortunately, use of that criteria also results in
    the discarding of all packets sent by another node using the same
    link-layer address.  Duplicate Address Detection will fail on
    interfaces that filter received packets in this manner:

    [snip]

    Thus, to perform Duplicate Address Detection correctly in the case
    where two interfaces are using the same link-layer address, an
    implementation must have a good understanding of the interface's
    multicast loopback semantics, and the interface cannot discard
    received packets simply because the source link-layer address is th=
e
    same as the interface's."

So, simply dropping frames whose source MAC =3D=3D local MAC is apparen=
tly not the right solution.

	Nicolas.
