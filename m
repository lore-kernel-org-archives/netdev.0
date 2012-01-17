From: =?ISO-8859-2?Q?=A9tefan_Gula?= <steweg@ynet.sk>
Subject: Re: [patch v2, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Tue, 17 Jan 2012 11:43:58 +0100
Message-ID: <CAGsizzLwCTpuZsZyx24T9WZy1DSJo+rfhDxLsE8UmeZOSxw+mA@mail.gmail.com>
References: <CAGsizz+x1GVNR9Pz=b7wO0ELx29=FMosfvhQWL5K26EpkwsUCg@mail.gmail.com>
 <1326745733.2564.14.camel@edumazet-laptop> <CAGsizz+2nH+Sx+7TjZwEeKBiHbio0BxoN7CgT4Sspp0EzRN6Ug@mail.gmail.com>
 <1326775643.2564.36.camel@edumazet-laptop> <CAGsizz+kgBB9APmU9dPExkGQvPUVa3m6qz3NvSguPYNuJQQ_7Q@mail.gmail.com>
 <1326788970.2564.52.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1326788970.2564.52.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

D=C5=88a 17. janu=C3=A1ra 2012 9:29, Eric Dumazet <eric.dumazet@gmail.c=
om> nap=C3=ADsal/a:
> Le mardi 17 janvier 2012 =C3=A0 09:04 +0100, =C5=A0tefan Gula a =C3=A9=
crit :
>> D=C5=88a 17. janu=C3=A1ra 2012 5:47, Eric Dumazet <eric.dumazet@gmai=
l.com> nap=C3=ADsal/a:
>> >
>> > 2) You call ipgre_tap_bridge_fini() from ipgre_exit_net() and
>> > ipgre_init_net(), thats completely bogus if CONFIG_NET_NS=3Dy
>> >
>> > Just remove the struct kmem_cache *ipgre_tap_bridge_cache
>> > and use instead kmalloc(sizeof(...))/kfree(ptr) instead.
>> >
>> As this is completely the same part of code from net/bridge/br_fdb.c=
,
>> can you give me a hint about how change that as I believe it should =
be
>> changed also there?
>
> Please dont copy code you dont understand :(
>
> bridge code is ok, but not yours, since you destroy the kmem_cache wh=
en
> a net namespace exits.
>
> Either you fix your code, either you change your memory allocations t=
o
> mere kmalloc()/kfree() calls and dont care of a private kmem_cache yo=
u
> have to create and destroy.
>
> Since you ask a SLAB_HWCACHE_ALIGN, the SLUB allocator will anyway me=
rge
> your kmem_cache with the standard one (kmalloc-64 I guess)
>
>
>
ok maybe I am getting it wrong, but I am little bit stuck here. I
recheck the original bridge code. The difference I recognize is that
in bridge code function:
br_fdb_init() and br_fdb_fini()
are called from module init and module exit functions:
br_init and br_deinit

in my code they are called from functions:
ipgre_init_net and ipgre_exit_net
instead of:
ipgre_init and ipgre_fini

To be honest I am not so familiar enough with kernel structure that I
see the difference on the first time. But I think that with your help
it can be done easily. The main idea was to create hash-table that is
used to determine the destination IPv4 address (part of the entry
structure). That hash-table should be different per each gretap
interface - I think that's the reason why I put those init and fini
inside ipgre_init_net and ipgre_exit_net. Am I right that the
placement of this calls is correct or not? If not where those calls
should be placed?

On the other hand I have no idea how to substitute those two function
with a code that you are suggesting kmalloc()/kfree(). I would be glad
if you can help me here by providing me example how to substitute
those two functions with kmalloc/kfree for the future usage (I am more
reverse engineer learner type of person than manuals reading one)
