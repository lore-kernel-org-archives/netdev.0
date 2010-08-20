From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v3] netfilter: save the hash of the tuple in the original
 direction for latter use
Date: Fri, 20 Aug 2010 23:36:44 +0800
Message-ID: <AANLkTinic7H0r7kAgsBiRAbn7MCeqxA0Gme7oOkmPUdJ@mail.gmail.com>
References: <1282316003-2966-1-git-send-email-xiaosuo@gmail.com>
 <1282317016.2484.173.camel@edumazet-laptop> <AANLkTimj=6HBdZK0WiPBxhm9YPG_8zRXEZyP--E7Shj8@mail.gmail.com>
 <1282318163.2484.212.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	akpm@linux-foundation.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:51309 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752944Ab0HTPhI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Aug 2010 11:37:08 -0400
In-Reply-To: <1282318163.2484.212.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 20, 2010 at 11:29 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le vendredi 20 ao=FBt 2010 =E0 23:22 +0800, Changli Gao a =E9crit :
>
>> I should keep the old way, but fix a race.
>>
>> =A0 =A0 =A0 =A0 if (unlikely(!nf_conntrack_hash_rnd_initted)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 get_random_bytes(&nf_conntrack_hash_=
rnd,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 size=
of(nf_conntrack_hash_rnd));
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nf_conntrack_hash_rnd_initted =3D 1;
>> =A0 =A0 =A0 =A0 }
>>
>> nf_conntrack_alloc() isn't called with in the nf_conntrack_lock. So
>> the above code maybe executed more than once on different CPUs. It i=
s
>> easy to fix with the cmpxchg() trick.
>
> Sure, please fix the race first.
>
> But as I said, its not critical, if one or two conntracks are hashed =
on
> wrong basis. They will eventually disappear after timeout.
>

Yes, and it isn't critical. I think this fix should be in a separate pa=
tch.


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
