From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH 1/3] vlan: Do not support clearing VLAN_FLAG_REORDER_HDR
Date: Tue, 24 May 2011 09:11:59 +0200
Message-ID: <4DDB5A3F.8050007@gmail.com>
References: <4DDAB72B.9050101@gmail.com> <4DDAC26C.2070601@candelatech.com>	<20110523140048.777fb378@nehalam>	<20110523.172047.1438754754048434316.davem@davemloft.net>	<m1y61x2htp.fsf@fess.ebiederm.org> <4DDADE52.8000008@candelatech.com> <m1boyt10n4.fsf@fess.ebiederm.org> <4DDB3226.8010404@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>,
	shemminger@linux-foundation.org, jpirko@redhat.com,
	xiaosuo@gmail.com, netdev@vger.kernel.org, kaber@trash.net,
	fubar@us.ibm.com, eric.dumazet@gmail.com, andy@greyhouse.net,
	jesse@nicira.com
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:61332 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751854Ab1EXHME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 03:12:04 -0400
Received: by wwa36 with SMTP id 36so6989926wwa.1
        for <netdev@vger.kernel.org>; Tue, 24 May 2011 00:12:02 -0700 (PDT)
In-Reply-To: <4DDB3226.8010404@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 24/05/2011 06:20, Ben Greear a =E9crit :
<snip>

> Then I think we should put it back with pf_packet logic. Possibly wit=
h
> a per-socket option to disable this and send it as only aux data if t=
hat
> is more efficient.

Why would we need a per-socket option for that?

If the socket listen on eth0, it probably expect to receive the raw pac=
ket. If it happens to expect=20
the untagged packet, it should listen on vlan2000.

The only reason I can imagine to listen on eth0 while expecting the pac=
ket to be untagged is to=20
listen to several VLAN at the same time on a single socket, while still=
 expecting the kernel or the=20
NIC to extract the vlan ID for us. But I don't have a real life use cas=
e for this in mind.

And maybe, for that particular situation, we should have a special vlan=
 interface, with wildcard=20
vlan ID:

        +--eth0.100
        |
eth0 --+--eth0.200
        |
        +--eth0.any

- Someone listening on eth0 would receive raw packet.
- Someone listening on eth0.100/eth0.200 would receive untagged packets=
 originally having 100/200 as=20
the VLAN ID.
- Someone listening on eth0.any would receive untagged packets original=
ly having any VLAN ID and=20
would not receive non-originally-tagged packets.

> If it turns out the NIC is not stripping VLAN tags for whatever reaso=
n,
> we might be able to optimize things so that it never does the HW emul=
ation
> so that it never has to un-do it later.

It might be very tricky to avoid any do-undo-redo situation. I will lat=
ter try and describe all the=20
possible situations: with/without hw-accel, with/without a protocol han=
dler registered on the parent=20
interface, with/without a child interface build on top of a particular =
parent interface and with the=20
corresponding VLAN ID...

	Nicolas.
