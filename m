From: =?ISO-8859-2?Q?=A9tefan_Gula?= <steweg@gmail.com>
Subject: Re: [patch v1, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Mon, 16 Jan 2012 14:42:12 +0100
Message-ID: <CAGsizzJr1nOBP=Sd8c3OrK8+BVr+dwT+_2y-9Xts4-NbZV_KwQ@mail.gmail.com>
References: <1326719999.2255.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <AE90C24D6B3A694183C094C60CF0A2F6D8AF46@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Laight <David.Laight@aculab.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AF46@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2012/1/16 David Laight <David.Laight@aculab.com>:
>> > + =A0 for (i =3D 0; i < GRETAP_BR_HASH_SIZE; i++) {
>> > + =A0 =A0 =A0 =A0 =A0 struct ipgre_tap_bridge_entry *entry;
>> > + =A0 =A0 =A0 =A0 =A0 struct hlist_node *h, *n;
>> > + =A0 =A0 =A0 =A0 =A0 hlist_for_each_entry_safe(entry, h, n,
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &tunnel->hash[i], hlist)
>> > + =A0 =A0 =A0 =A0 =A0 {
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long this_timer;
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 this_timer =3D entry->ageing=
_timer + delay;
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (time_before_eq(this_time=
r, jiffies))
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ipgre_tap_br=
idge_delete(entry);
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else if (time_before(this_ti=
mer, next_timer))
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 next_timer =3D=
 this_timer;
>> > + =A0 =A0 =A0 =A0 =A0 }
>> > + =A0 }
>> > + =A0 spin_unlock_bh(&tunnel->hash_lock);
>> > + =A0 mod_timer(&tunnel->gc_timer, round_jiffies(next_timer + HZ/4=
));
>>
>> wow... why setup a 250 ms timer, if entries are valid 300 seconds ?
>
> Isn't that code trying to wakeup 250ms after the first expiry of any
> of its items?
>
> Do you even need a timer at all?
>
> It may be enough to just put a timestamp into each entry
> and tidy up when scanning one of the hash chains in (say)
> the 'add item' path - when you need write access anyway.
>
> A hash table might not be the best structure either!
> The hash lookup is still o(n) for n >> table_size.
> It also may be likely that you'll do repeated lookups for a small
> number of items - in which case using a hash to cache recent lookups
> might be useful (maybe with some type of balanced tree structure)
>
> =A0 =A0 =A0 =A0David
>
>

That part of code is modified from original linux bridge code, as I
wanted to avoid of developing something that was already developed.
The timer is actually needed to network


--=20
Stefan Gula
