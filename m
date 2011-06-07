From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_packet: prevent information leak
Date: Mon, 06 Jun 2011 22:42:44 -0700 (PDT)
Message-ID: <20110606.224244.1558496117122074196.davem@davemloft.net>
References: <1307422939.2642.57.camel@edumazet-laptop>
	<20110606.222416.1114593259198630297.davem@davemloft.net>
	<1307425119.2642.63.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kaber@trash.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33039 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825Ab1FGFnu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2011 01:43:50 -0400
In-Reply-To: <1307425119.2642.63.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 07 Jun 2011 07:38:39 +0200

> Le lundi 06 juin 2011 =E0 22:24 -0700, David Miller a =E9crit :
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Tue, 07 Jun 2011 07:02:19 +0200
>>=20
>> > In 2.6.27, commit 393e52e33c6c2 (packet: deliver VLAN TCI to users=
pace)
>> > added a small information leak.
>> >=20
>> > Add padding field and make sure its zeroed before copy to user.
>> >=20
>> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> > CC: Patrick McHardy <kaber@trash.net>
>>=20
>> I fear this will change the size of these structures on some weird
>> architecture.  Doesn't ARM, for example, have weird rules
>> wrt. alignment and structure sizing when "smaller than word" element=
s
>> are involved?
>>=20
>> That's why we need __packed on:
>>=20
>> struct nd_opt_hdr {
>> 	__u8		nd_opt_type;
>> 	__u8		nd_opt_len;
>> } __packed;
>>=20
>> for example.
>>=20
>> Probably safe to just do a memset of the tail, and the constant leng=
th
>> will evaluate to zero on these weird platforms.  On others, where th=
e
>> padding does matter, the memset will emit the same code as your new
>> assignments do.
>=20
> It should not matter for these structures, or 393e52e33c6c2 would hav=
e
> break applications on all arches (not only ARM), since it enlarged th=
em
> without any warning ;)

Indeed.  Ok, I'm convinced.

Applied and queued up for -stable, thanks!
