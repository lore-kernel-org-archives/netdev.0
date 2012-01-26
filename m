From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] l2tp: l2tp_ip - fix possible oops on packet receive
Date: Wed, 25 Jan 2012 21:45:52 -0500 (EST)
Message-ID: <20120125.214552.52611932413304658.davem@davemloft.net>
References: <1327495145-6748-1-git-send-email-jchapman@katalix.com>
	<1327496817.2425.32.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jchapman@katalix.com, netdev@vger.kernel.org, alex@m3x.org,
	ben@decadent.org.uk
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54965 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751271Ab2AZCqX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2012 21:46:23 -0500
In-Reply-To: <1327496817.2425.32.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 25 Jan 2012 14:06:57 +0100

> Le mercredi 25 janvier 2012 =E0 12:39 +0000, James Chapman a =E9crit =
:
>> When a packet is received on an L2TP IP socket (L2TPv3 IP link
>> encapsulation), the l2tpip socket's backlog_rcv function calls
>> xfrm4_policy_check(). This is not necessary, since it was called
>> before the skb was added to the backlog. With CONFIG_NET_NS enabled,
>> xfrm4_policy_check() will oops if skb->dev is null, so this trivial
>> patch removes the call.
>>=20
>> This bug has always been present, but only when CONFIG_NET_NS is
>> enabled does it cause problems. Most users are probably using UDP
>> encapsulation for L2TP, hence the problem has only recently
>> surfaced.
>>=20
> ...
>> Signed-off-by: James Chapman <jchapman@katalix.com>
>>=20
>> ---
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: alex <alex@m3x.org>
> Cc: Ben Hutchings <ben@decadent.org.uk>

Applied and queued up for -stable, thanks.
