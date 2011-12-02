From: David Miller <davem@davemloft.net>
Subject: Re: Bug in computing data_len in tcp_sendmsg?
Date: Fri, 02 Dec 2011 13:13:04 -0500 (EST)
Message-ID: <20111202.131304.981034697414242002.davem@davemloft.net>
References: <1322827188.2607.19.camel@edumazet-laptop>
	<1322840663.2762.26.camel@edumazet-laptop>
	<1322841935.2762.33.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: subramanian.vijay@gmail.com, therbert@google.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47538 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932085Ab1LBSNJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 13:13:09 -0500
In-Reply-To: <1322841935.2762.33.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 02 Dec 2011 17:05:35 +0100

> Le vendredi 02 d=E9cembre 2011 =E0 16:44 +0100, Eric Dumazet a =E9cri=
t :
>=20
>> [PATCH net-next] tcp: fix tcp_trim_head()
>>=20
>> commit f07d960df3 (tcp: avoid frag allocation for small frames)
>> breaked assumption in tcp stack that skb is either linear (data_len =
=3D=3D
>> 0), either fully fragged (data_len =3D=3D len)
>>=20
>> Thanks to Vijay for providing a very detailed explanation.
>>=20
>> Reported-by: Vijay Subramanian <subramanian.vijay@gmail.com>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> ---
>=20
> Another problem is the possible misalignement of skb->data if/when we
> receive an ACK of an odd (not a 4 multiple) tcp sequence.
>=20
> So when/if packet is restransmited, tcp header (and IP header as well=
)
> could be misaligned.
>=20
> Hmm, I probably miss something obvious, since this problem could happ=
en
> for linear skbs before my patch ?

Unfortunately, even if netfilter or the packet scheduler pulled data, t=
his
misalignment wouldn't happen before your change.

Maybe we should revert your frag allocation avoidance change until we c=
an
sort this out.
