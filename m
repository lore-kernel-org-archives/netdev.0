From: Patrick McHardy <kaber@trash.net>
Subject: Re: mmotm 2010-04-28 - RCU whinges
Date: Mon, 10 May 2010 18:03:05 +0200
Message-ID: <4BE82E39.6080603@trash.net>
References: <1272865137.2173.179.camel@edumazet-laptop>	 <1272865267.2173.180.camel@edumazet-laptop>	 <1272865436.2173.182.camel@edumazet-laptop>	 <20100502.225509.233880079.davem@davemloft.net>	 <4BE8290A.2080707@trash.net> <1273506968.2221.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Valdis.Kletnieks@vt.edu,
	akpm@linux-foundation.org, peterz@infradead.org,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273506968.2221.19.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Le lundi 10 mai 2010 =E0 17:40 +0200, Patrick McHardy a =E9crit :
>> David Miller wrote:
>>> From: Eric Dumazet <eric.dumazet@gmail.com>
>>> Date: Mon, 03 May 2010 07:43:56 +0200
>>>
>>>> Le lundi 03 mai 2010 =E0 07:41 +0200, Eric Dumazet a =E9crit :
>>>>
>>>>> Oops scratch that, I'll resend a correct version.
>>>>>
>>>>>
>>>> Sorry, patch _is_ fine, I had one brain collapse when re-reading i=
t, I
>>>> thought a different mutex was in use in one of the functions.
>>> Ok, Patrick please review, thanks.
>> Actually we don't need the rcu_dereference() calls at all since
>> registration and unregistration are protected by the mutexes.
>>
>> I queued this patch in nf-next, the only reason why I haven't
>> submitted it yet is that I was unable to get git to cleanly export
>> only the proper set of patches meant for -next due to a few merges,
>> it insists on including 5 patches already merged upstream. If you
>> don't mind ignoring the first 5 patches in the series, I'll send a
>> pull request tonight.
>>
>=20
> This will clash with upcoming RCU patches, where rcu protected pointe=
r
> cannot be directly accessed without lockdep splats.
>=20
> We will need one day or another a rcu_...(nf_conntrack_event_cb)

Thanks for the information, I didn't realize that when looking at
those patches. So I guess the correct fix once those patches are
merged would be to use rcu_assign_protected() and rcu_access_pointer().
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
