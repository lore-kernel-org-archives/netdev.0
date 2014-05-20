From: Valdis.Kletnieks@vt.edu
Subject: Re: Revert 462fb2af9788a82a534f8184abfde31574e1cfa0 (bridge : Sanitize skb before it enters the IP stack)
Date: Tue, 20 May 2014 00:55:49 -0400
Message-ID: <14456.1400561749@turing-police.cc.vt.edu>
References: <537621AC.1060409@davidnewall.com> <5379FFFD.1050705@davidnewall.com> <20140519140119.GA24523@breakpoint.cc>
            <537A12EA.4060604@davidnewall.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1400561749_1944P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	bridge@lists.linux-foundation.org
To: David Newall <davidn@davidnewall.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lennier.cc.vt.edu ([198.82.162.213]:41393 "EHLO
	lennier.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbaETE7D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2014 00:59:03 -0400
In-Reply-To: Your message of "Mon, 19 May 2014 23:49:22 +0930."
             <537A12EA.4060604@davidnewall.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1400561749_1944P
Content-Type: text/plain; charset=us-ascii

On Mon, 19 May 2014 23:49:22 +0930, David Newall said:

> How does a packet get fragmented in this case?  Does it only happen when
> bridging to a device with smaller MTU?  That scenario sounds quite
> un-bridge-like.  It also sounds like something that can be handled by
> real routing.

Which doesn't change the fact that you *will* get clowns who take a box that
has a 10G card on a jumbogram-enabled subnet that's running with an MTU of
9000, and a 1G at MTU 1500 on the other, and try to bridge rather than route.
(Did you know that you can actually mount an NFS filesystem across that? And
that ls and cat and friends will work *just fine*? Until you hit a file that's
more than 1.5 in size, that is. And when you do a traceroute to the wedged
client, it tells you it's on the 10G network, so you have no idea why you're
seeing an MTU issue.  Don't ask how I know this - let's just say that
supporting HPC users is never boring. :)

So yes, we *do* need to do something sensible there - either frag the packet
on the way out, or something.  It *would* be nice if we could drop the
packet and send an ICMP Frag Needed back - except it's unclear what IP
you use as the source address for the ICMP....


--==_Exmh_1400561749_1944P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBU3rgVQdmEQWDXROgAQKQfw/9GcqjwTRblsTMBAzRms+9859yNW++iOKG
N4cYN4Y1eip5ygc7ijvkiUOtTBq4UwwG+9rNkj0UwD1ZWCWiA9glN/n5bGvPY8qX
brWW9QJAitZwN3yVJDc7+S6KyP62j+0q0f0xlFlfDNvEwNJ17d2v9ZG8PpzTJpfk
bqxIIuTJzLY5UUjXM5RXGkDiw62eqb4e7aGL+nKOH52C/r8byEjY0yl2AmiqCAQD
aFM8kLAITz/f2UB/KaTtu3i9b1Kv0Um/sRTHxULqN1jYHW1MqnenuAYw+ushoBTZ
jRjpN2KdUDW7xGYz5Lx8bVnMxU8kJs5kmMVjnjbRsYmDA5v1jcoac+mGDLiQ8O6K
6VuJIrZ8e5pnJWFa2kcg1Syi2ca+Mi+pFRJGboMZQYw9KTQzx5lfQtgFdsyme40N
0A+MUc6eVeSCXITjmwhCmYanxLeEpOw4xlwYANoBWRXlUGCj4knB6zW5s6JwLrsu
9eGhag+t3mCYbM1cRN/Jru2Y7IB7bApnnKZsUdWkg0RoJJLX2WHF/26/u2Edi9He
FawVStF76ZWtWNtZElrdFy1FPvg+jBjVPuzZs+tjyH5LW11Qlmt757ISSn/vnbCX
sL4LNv8SXioBZenMMH4+sYh9Wh/LvyIn7egggzdvAzzYDU7Tm+niWnFJm2HLGETi
svyoYnJozT4=
=KX4i
-----END PGP SIGNATURE-----

--==_Exmh_1400561749_1944P--
