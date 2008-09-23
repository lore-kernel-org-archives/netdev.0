From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: xfrm_state locking regression...
Date: Tue, 23 Sep 2008 16:30:06 +0300
Message-ID: <48D8EF5E.1060500@iki.fi>
References: <20080923052239.GA26233@gondor.apana.org.au> <48D88BCC.5030806@iki.fi> <20080923064707.GA26836@gondor.apana.org.au> <48D8B967.8000107@iki.fi> <20080923112416.GA28946@gondor.apana.org.au> <48D8DC28.1020001@iki.fi> <20080923121414.GB29257@gondor.apana.org.au> <48D8E045.8040508@iki.fi> <20080923125615.GC29524@gondor.apana.org.au> <48D8E8A9.8050100@iki.fi> <20080923130709.GA29902@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:18308 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031AbYIWNaK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 09:30:10 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1733007fgg.17
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 06:30:09 -0700 (PDT)
In-Reply-To: <20080923130709.GA29902@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Tue, Sep 23, 2008 at 04:01:29PM +0300, Timo Ter=E4s wrote:
>> So, what to do?
>> 1. Go back to: list_del_rcu, xfrm_state_hold(all.next) on delete and
>>    xfrm_state_put(all.next) on destruct.
>> 2. Add per-entry hlist of walkers currently referencing it.
>> 3. Use the global walker list.
>>
>> 1 can keep memory allocated until userland wakes up. 2 & 3 can make
>> the delete of that entry slow if there's many walkers suspended.
>=20
> I'd cross 3 off the list because 2 is just so much better :)
>=20
> I'd slightly lean towards 2 but now that you mention it yes even
> that is vulnerable to loads of dumpers sitting on the same entry.
> So SELINUX folks wouldn't like that :)

Umm... right. It's a tricky problem. Cannot think of perfect
solution atm. But I guess 3 is in general case the best. But in
worst case scenarios 1 performs better.

I have no strong opinion either way. So what ever you want, I'm
happy to provide a patch for.

>> Btw. the current stuff in net-next is broken. There's no locking
>> for xfrm_state_walkers list handling.
>=20
> What about xfrm_cfg_mutex?

It's used only in xfrm_state_gc_task. xfrm_state_walk_{init,done}
touch xfrm_state_walks list without locking properly. At least in
the version I'm looking (=3D net-next-2.6 via git web interface).

- Timo
