From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] neigh: increase unres_qlen by one magnitude
Date: Tue, 08 Nov 2011 23:45:01 +0100
Message-ID: <1320792301.26025.21.camel@edumazet-laptop>
References: <1320783085.2588.17.camel@edumazet-laptop>
	 <20111108.172448.2101648110512252549.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:36216 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753370Ab1KHWpG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 17:45:06 -0500
Received: by wyh15 with SMTP id 15so1042829wyh.19
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2011 14:45:04 -0800 (PST)
In-Reply-To: <20111108.172448.2101648110512252549.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 08 novembre 2011 =C3=A0 17:24 -0500, David Miller a =C3=A9crit=
 :

> Pretty risky don't you think?
>=20

Yes :)

> So now we'll allow essentially any remote machine to force us to hold
> on to memory on the order of (32 * num_ips_in_subnet) for each IP
> address configured.
>=20

Exact limit is 32 * min(num_ips_in_subnet, 1024) : 32768 packets

(because gc_thresh3 is 1024 : max allowed number of neighbors)

> Just spam UDP or ICMP packets with a source address iterating over
> addresses in one of the host's subnets.  If the subnet space is
> relatively large, chances are %99 of those IPs won't respond to ARP
> and we'll queue up the ICMP replies.
>=20
> Probably what will trigger first, actually, is we'll hit the per-cpu
> ICMP socket send buffer limit.  Because we won't even get to the
> point in the TX path where we will early orphan the SKB.
>=20
> So essentially this will stop ICMP responses completely for all
> traffic processed on that cpu.
>=20
> I realize you're trying to address a very real problem, but I'm just
> not sure at all that unilaterally increasing the value like this is
> safe.

Since you speak of icmp sock, its limit is more governed by cumulative
skb truesizes.

Maybe we can do the same for unres_qlen, and setup a byte limit instead
of 3 packets limit (say 64Kbytes of truesize per destination)
