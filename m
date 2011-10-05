From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IPv4 multicast and mac-vlans acting weird on 3.0.4+
Date: Wed, 05 Oct 2011 21:54:09 +0200
Message-ID: <1317844449.3457.3.camel@edumazet-laptop>
References: <4E8C89EE.3090600@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63989 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933233Ab1JETyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 15:54:22 -0400
Received: by wyg34 with SMTP id 34so2077442wyg.19
        for <netdev@vger.kernel.org>; Wed, 05 Oct 2011 12:54:21 -0700 (PDT)
In-Reply-To: <4E8C89EE.3090600@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 05 octobre 2011 =C3=A0 09:46 -0700, Ben Greear a =C3=A9crit=
 :
> This is on a hacked 3.0.4 kernel...
>=20
> I am seeing an issue where an IPv4 mcast receiver will not receive
> a 1473 or larger byte mcast message, but will receive a 1472.  The di=
fference
> being that 1473 ends up being two packets on the wire.  It works on
> 802.1Q VLANs, VETH interfaces and real Ethernet.  It does not work
> on a mac-vlan hanging off the VETH.
>=20
> I see packets received on the macvlan in tshark, and they appear corr=
ect.  No
> obvious errors in the macvlan port stats or netstat -s,
> and the 'ss' tool doesn't appear to support UDP sockets at all.
>=20
> So, I'm about to go digging into the code, but if anyone has any
> suggestions for places to look, please let me know!
>=20

Well, problem is defragmentation and macvlan cooperation.

Multicast messages are broadcasted on all macvlan ports.

But IP defrag will probably deliver a single final frame.

We probably need to handle defrag in macvlan before broadcasting to all
ports.
