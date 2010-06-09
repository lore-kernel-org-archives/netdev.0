From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH nf-next-2.6 2/2] conntrack: per_cpu untracking
Date: Wed, 09 Jun 2010 14:45:12 +0200
Message-ID: <4C0F8CD8.6040100@trash.net>
References: <1271941082.14501.189.camel@jdb-workstation>	 <Pine.LNX.4.64.1004222213290.10919@ask.diku.dk>	 <1272056237.4599.7.camel@edumazet-laptop>	 <Pine.LNX.4.64.1004241219280.32071@ask.diku.dk>	 <1272139861.20714.525.camel@edumazet-laptop>	 <1272292568.13192.43.camel@jdb-workstation>	 <1275340896.2478.26.camel@edumazet-laptop>	 <AANLkTikw3uonDB4nPXg8FVFN_07F_wq0SA_ayyAHL6VM@mail.gmail.com>	 <1275368732.2478.88.camel@edumazet-laptop> <4C04DE73.6050605@trash.net>	 <1275388310.2738.2.camel@edumazet-laptop> <4C04E3E2.7020209@trash.net>	 <1275409203.2738.227.camel@edumazet-laptop> <4C08E62A.9020607@trash.net>	 <AANLkTilKEpFTg5bH8d9UE3a3DVJNAGYz10Jgkt6lXtJ0@mail.gmail.com>	 <4C08F1A4.2050906@trash.net>  <1275654964.2482.150.camel@edumazet-laptop>	 <1275668732.2482.201.camel@edumazet-laptop>	
  <1275682522.2490.6.camel@edumazet-laptop>  <4C0E53C4.7090308@trash.net>	 <1276008733.2486.177.camel@edumazet-laptop> <1276009946.2486.216.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1276009946.2486.216.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Le mardi 08 juin 2010 =C3=A0 16:52 +0200, Eric Dumazet a =C3=A9crit :
>  =20
>> Le mardi 08 juin 2010 =C3=A0 16:29 +0200, Patrick McHardy a =C3=A9cr=
it :
>>    =20
>>> On 04.06.2010 22:15, Eric Dumazet wrote:
>>>      =20
>>>> NOTRACK makes all cpus share a cache line on nf_conntrack_untracke=
d
>>>> twice per packet, slowing down performance.
>>>>
>>>> This patch converts it to a per_cpu variable.
>>>>
>>>> We assume same cpu is used for a given packet, entering and exitin=
g the
>>>> NOTRACK state.
>>>>        =20
>>> That doesn't seem to be a valid assumption, the conntrack entry is
>>> attached to the skb and processing in the output path might get
>>> preempted and rescheduled to a different CPU.
>>>      =20
>> Thats unfortunate.
>>
>> Ok, only choice then is to not change refcount on the untracked ct, =
and
>> keep a shared (read only after setup time) untrack structure.
>>
>>
>>    =20
>
> Oh well, re-reading my patch, I dont see why I said this in Changelog=
 :)
>
> We lazily select the untrack structure in one cpu, then keep the poin=
ter
> to this untrack structure, attached to ct.
>
> The (still atomic) increment / decrement of refcount is done on the
> saved pointer, not on actual per_cpu structure.
>
> So if a packet is rescheduled on a different CPU, second cpu will "on=
ly"
> dirty cache line of other cpu, it probably almost never happens...
>  =20

Indeed, you're right of course.
> Thanks
>
> [PATCH nf-next-2.6 2/2] conntrack: per_cpu untracking
>
> NOTRACK makes all cpus share a cache line on nf_conntrack_untracked
> twice per packet, slowing down performance.
>
> This patch converts it to a per_cpu variable.
>  =20
Applied, thanks Eric.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
