From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] conntrack: use SLAB_DESTROY_BY_RCU for nf_conn structs
Date: Wed, 25 Mar 2009 19:24:04 +0100
Message-ID: <49CA76C4.2090409@trash.net>
References: <OF1FEA88FD.D6B88765-ONC1257582.003A487F-C1257582.003ACE3A@transmode.se>	 <49C77D71.8090709@trash.net>	 <OF8A05682D.BA831A09-ONC1257582.0043892E-C1257582.004440BD@transmode.se>	 <49C780AD.70704@trash.net>	 <OF20814141.D78C9170-ONC1257582.0060B64A-C1257582.00614FDC@transmode.se>	 <49C7CB9B.1040409@trash.net>	 <OFBD3D31D8.7AD81126-ONC1257583.002C5C2B-C1257583.002DFF13@transmode.se>	 <49C8A415.1090606@cosmosbay.com>	 <OF9168DCC3.5E31F8E4-ONC1257583.003B48CC-C1257583.003C0A5E@transmode.se>	 <49C8CCF4.5050104@cosmosbay.com> <1237907850.12351.80.camel@sakura.staff.proxad.net> <49C8FBCA.40402@cosmosbay.com> <49CA6F9A.9010806@cosmosbay.com> <49CA7255.20807@trash.net> <49CA74CA.1040603@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mbizon@freebox.fr, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Joakim Tjernlund <Joakim.Tjernlund@transmode.se>,
	avorontsov@ru.mvista.com, netdev@vger.kernel.org,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49CA74CA.1040603@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Patrick McHardy a =E9crit :
>>> +static struct hlist_nulls_node *ct_get_first(struct seq_file *seq)
>>>  {
>>>      struct net *net =3D seq_file_net(seq);
>>>      struct ct_iter_state *st =3D seq->private;
>>> -    struct hlist_node *n;
>>> +    struct hlist_nulls_node *n;
>>> =20
>>>      for (st->bucket =3D 0;
>>>           st->bucket < nf_conntrack_htable_size;
>>>           st->bucket++) {
>>>          n =3D rcu_dereference(net->ct.hash[st->bucket].first);
>>> -        if (n)
>>> +        if (!is_a_nulls(n))
>>>              return n;
>>>      }
>>>      return NULL;
>>>  }
>> Don't we need to make sure the entry is not reused while dumping
>> it?
>>
>=20
> Ah yes, I forgot that for UDP/TCP I had to change locking on this par=
t.
> Because messing with reference count was crazy...
> But in UDP/TCP we have different spinlock for each chain, so hold tim=
e
> was small enough.
>=20
> So I guess that with central conntrack lock, we need to take referenc=
es on entries
> while dumping them.

Yes, I think so too.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
