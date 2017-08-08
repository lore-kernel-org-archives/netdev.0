From: Vincent Bernat <vincent@bernat.im>
Subject: Re: [net-next v1] net: ipv6: avoid overhead when no custom FIB rules are installed
Date: Tue, 08 Aug 2017 16:50:37 +0200
Message-ID: <87h8xinmf6.fsf@luffy.cx>
References: <20170808115121.21283-1-vincent@bernat.im>
        <66e3d00a-6788-2e86-9563-fc1424a6a250@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Jiri Pirko <jiri@mellanox.com>, netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:50502 "EHLO bart.luffy.cx"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752010AbdHHO5l (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 8 Aug 2017 10:57:41 -0400
In-Reply-To: <66e3d00a-6788-2e86-9563-fc1424a6a250@gmail.com> (David Ahern's
        message of "Tue, 8 Aug 2017 08:46:23 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 =E2=9D=A6  8 ao=C3=BBt 2017 08:46 -0600, David Ahern <dsahern@gmail.com>=
=C2=A0:

>> diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
>> index 2f29e4e33bd3..693c27ede40e 100644
>> --- a/net/ipv6/fib6_rules.c
>> +++ b/net/ipv6/fib6_rules.c
>> @@ -63,19 +63,32 @@ unsigned int fib6_rules_seq_read(struct net *net)
>>  struct dst_entry *fib6_rule_lookup(struct net *net, struct flowi6 *fl6,
>>  				   int flags, pol_lookup_t lookup)
>>  {
>> -	struct fib_lookup_arg arg =3D {
>> -		.lookup_ptr =3D lookup,
>> -		.flags =3D FIB_LOOKUP_NOREF,
>> -	};
>> -
>>  	/* update flow if oif or iif point to device enslaved to l3mdev */
>>  	l3mdev_update_flow(net, flowi6_to_flowi(fl6));
>
> The l3mdev_update_flow can be moved to the has_custom_rules block.
> l3mdev requires FIB rules for the lookups to work, so no rules means no
> l3mdev configured.
>
> Rest looks good to me.

I suspected that it could be moved. I'll update the patch tomorrow.
--=20
Choose variable names that won't be confused.
            - The Elements of Programming Style (Kernighan & Plauger)
