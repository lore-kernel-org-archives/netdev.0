From: Patrick McHardy <kaber@trash.net>
Subject: Re: DDoS attack causing bad effect on conntrack searches
Date: Tue, 01 Jun 2010 12:41:38 +0200
Message-ID: <4C04E3E2.7020209@trash.net>
References: <1271941082.14501.189.camel@jdb-workstation>	 <q2h412e6f7f1004220613m488c2ee4r6d24a8d1e65997d4@mail.gmail.com>	 <4BD04C74.9020402@trash.net> <1271946961.7895.5665.camel@edumazet-laptop>	 <1271948029.7895.5707.camel@edumazet-laptop>	 <20100422155123.GA2524@linux.vnet.ibm.com>	 <1271952128.7895.5851.camel@edumazet-laptop>	 <Pine.LNX.4.64.1004222213290.10919@ask.diku.dk>	 <1272056237.4599.7.camel@edumazet-laptop>	 <Pine.LNX.4.64.1004241219280.32071@ask.diku.dk>	 <1272139861.20714.525.camel@edumazet-laptop>	 <1272292568.13192.43.camel@jdb-workstation>	 <1275340896.2478.26.camel@edumazet-laptop>	 <AANLkTikw3uonDB4nPXg8FVFN_07F_wq0SA_ayyAHL6VM@mail.gmail.com>	 <1275368732.2478.88.camel@edumazet-laptop>  <4C04DE73.6050605@trash.net> <1275388310.2738.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>, hawk@comx.dk,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	paulmck@linux.vnet.ibm.com,
	Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1275388310.2738.2.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Le mardi 01 juin 2010 =E0 12:18 +0200, Patrick McHardy a =E9crit :
>=20
>> If a new conntrack is created in PRE_ROUTING or LOCAL_OUT, it will b=
e
>> added to the unconfirmed list and moved to the hash as soon as the
>> packet passes POST_ROUTING. This means the number of unconfirmed ent=
ries
>> created by the network is bound by the number of CPUs due to BH
>> processing. The number created by locally generated packets is unbou=
nd
>> in case of preemptible kernels however.
>>
>=20
> OK, we should have a percpu list then.

Yes, that makes sense.

> BTW, I notice nf_conntrack_untracked is incorrectly annotated
> '__read_mostly'.
>=20
> It can be written very often :(
>=20
> Should'nt we special case it and let be really const ?

That would need quite a bit of special-casing to avoid touching
the reference counts. So far this is completely hidden, so I'd
say it just shouldn't be marked __read_mostly. Alternatively we
can make "untracked" a nfctinfo state.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
