From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Wed, 29 Oct 2008 11:19:50 +0100
Message-ID: <490838C6.4060304@cosmosbay.com>
References: <490795FB.2000201@cosmosbay.com>	<20081028.220536.183082966.davem@davemloft.net>	<49081D67.3050502@cosmosbay.com> <20081029.015659.223371561.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040002090100050804010408"
Cc: shemminger@vyatta.com, benny+usenet@amorsen.dk, minyard@acm.org,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	cl@linux-foundation.org, a.p.zijlstra@chello.nl, christian@myri.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:50236 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753238AbYJ2KU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 06:20:26 -0400
In-Reply-To: <20081029.015659.223371561.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040002090100050804010408
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Wed, 29 Oct 2008 09:23:03 +0100
>=20
>> David Miller a =E9crit :
>>> From: Eric Dumazet <dada1@cosmosbay.com>
>>> Date: Tue, 28 Oct 2008 23:45:15 +0100
>>>
>>>> I will submit a new patch serie tomorrow, with :
>>>>
>>>> Patch 1 : spinlocks instead of rwlocks, and bug spotted by Christian=
 Bell
>>>>
>>>> Patch 2 : splited on two parts (2 & 3) , one for IPV4, one for IPV6,=
=20
>>> I very much look forward to this :-)
>>> I like these changes and can't wait to add them to net-next-2.6
>> Thanks David, please find first updated patch 1
>=20
> Applied, please (re-)send the current version of patch 2 as well.

I found a fatal bug in /proc/net/udp handling, sorry.

[PATCH] udp: udp_get_next() should use spin_unlock_bh()

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--------------040002090100050804010408
Content-Type: text/plain;
 name="udp_3.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="udp_3.patch"

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 5ba0340..ced8203 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1579,7 +1579,7 @@ static struct sock *udp_get_next(struct seq_file *seq, struct sock *sk)
 	} while (sk && (!net_eq(sock_net(sk), net) || sk->sk_family != state->family));
 
 	if (!sk) {
-		spin_unlock(&state->udp_table->hash[state->bucket].lock);
+		spin_unlock_bh(&state->udp_table->hash[state->bucket].lock);
 		return udp_get_first(seq, state->bucket + 1);
 	}
 	return sk;

--------------040002090100050804010408--
