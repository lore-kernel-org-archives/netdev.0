From: Patrick McHardy <kaber@trash.net>
Subject: Re: DDoS attack causing bad effect on conntrack searches
Date: Fri, 23 Apr 2010 12:55:38 +0200
Message-ID: <4BD17CAA.4090708@trash.net>
References: <1271941082.14501.189.camel@jdb-workstation>	 <q2h412e6f7f1004220613m488c2ee4r6d24a8d1e65997d4@mail.gmail.com>	 <4BD04C74.9020402@trash.net> <1271946961.7895.5665.camel@edumazet-laptop>	 <1271948029.7895.5707.camel@edumazet-laptop>	 <20100422155123.GA2524@linux.vnet.ibm.com>	 <1271952128.7895.5851.camel@edumazet-laptop>	 <Pine.LNX.4.64.1004222213290.10919@ask.diku.dk> <1271970199.7895.6482.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Dangaard Brouer <hawk@diku.dk>, paulmck@linux.vnet.ibm.com,
	Changli Gao <xiaosuo@gmail.com>, hawk@comx.dk,
	Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1271970199.7895.6482.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Le jeudi 22 avril 2010 =E0 22:38 +0200, Jesper Dangaard Brouer a =E9c=
rit :
>> On Thu, 22 Apr 2010, Eric Dumazet wrote:
>>
>>> Le jeudi 22 avril 2010 =E0 08:51 -0700, Paul E. McKenney a =E9crit =
:
>>>> On Thu, Apr 22, 2010 at 04:53:49PM +0200, Eric Dumazet wrote:
>>>>> Le jeudi 22 avril 2010 =E0 16:36 +0200, Eric Dumazet a =E9crit :
>>>>>
>>>>> If we can do the 'retry' a 10 times, it means the attacker was re=
ally
>>>>> clever enough to inject new packets (new conntracks) at the right
>>>>> moment, in the right hash chain, and this sounds so higly incredi=
ble
>>>>> that I cannot believe it at all :)
>>>> Or maybe the DoS attack is injecting so many new conntracks that a=
 large
>>>> fraction of the hash chains are being modified at any given time?
>>>>
>> I think its plausable, there is a lot of modification going on.
>> Approx 40.000 deletes/sec and 40.000 inserts/sec.
>> The hash bucket size is 300032, and with 80000 modifications/sec, we=
 are=20
>> (potentially) changing 26.6% of the hash chains each second.
>>
>=20
> OK but a lookup last a fraction of a micro second, unless interrupted=
 by
> hard irq.
>=20
> Probability of a change during a lookup should be very very small.
>=20
> Note that the scenario for a restart is :
>=20
> The lookup go through the chain.
> While it is examining one object, this object is deleted.
> The object is re-allocated by another cpu and inserted to a new chain=
=2E

I think another scenario that seems a bit more likely would be
that a new entry is added to the chain after it was fully searched.
Perhaps we could continue searching at the last position if the
last entry is not a nulls entry to improve this.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
