From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH tip/core/rcu 05/13] net: add checking to rcu_dereference()
	primitives
Date: Sun, 14 Feb 2010 09:34:43 +0100
Message-ID: <e2d7436a1002140034h74617164p1a5dc90df3587095@mail.gmail.com>
References: <20100212000016.GA25781@linux.vnet.ibm.com>
	 <1265932839-25899-5-git-send-email-paulmck@linux.vnet.ibm.com>
	 <1265948152.2891.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	linux-kernel@vger.kernel.org, mingo@elte.hu, laijs@cn.fujitsu.com,
	dipankar@in.ibm.com, akpm@linux-foundation.org,
	mathieu.desnoyers@polymtl.ca, josh@joshtriplett.org,
	dvhltc@us.ibm.com, niv@us.ibm.com, tglx@linutronix.de,
	peterz@infradead.org, rostedt@goodmis.org, Valdis.Kletnieks@vt.edu,
	dhowells@redhat.com, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1265948152.2891.25.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2010/2/12 Eric Dumazet <eric.dumazet@gmail.com>:
> Le jeudi 11 f=C3=A9vrier 2010 =C3=A0 16:00 -0800, Paul E. McKenney a =
=C3=A9crit :
[...]
>> @@ -1654,12 +1654,12 @@ static struct dn_route *dn_rt_cache_get_firs=
t(struct seq_file *seq)
>>
>> =C2=A0 =C2=A0 =C2=A0 for(s->bucket =3D dn_rt_hash_mask; s->bucket >=3D=
 0; --s->bucket) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rcu_read_lock_bh();
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rt =3D dn_rt_hash_table[=
s->bucket].chain;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rt =3D rcu_dereference_b=
h(dn_rt_hash_table[s->bucket].chain);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (rt)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 break;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rcu_read_unlock_bh(=
);
>> =C2=A0 =C2=A0 =C2=A0 }
>> - =C2=A0 =C2=A0 return rcu_dereference(rt);
>> + =C2=A0 =C2=A0 return rt;
>> =C2=A0}

Isn't there a bug? Looks like data pointed to by rt should be
protected by RCU, but the rcu_read_lock is withdrawn before access.

Best Regards,
Micha=C5=82 Miros=C5=82aw
