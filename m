From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Fw: [Bug 13339] New: rtable leak in ipv4/route.c
Date: Tue, 19 May 2009 19:22:01 +0200
Message-ID: <20090519172200.GB2749@ami.dom.local>
References: <20090519123417.GA7376@ff.dom.local> <4A12D10D.3000504@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lav@yar.ru, Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.184]:35224 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751701AbZESRWN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 13:22:13 -0400
Received: by fk-out-0910.google.com with SMTP id 18so1921805fkq.5
        for <netdev@vger.kernel.org>; Tue, 19 May 2009 10:22:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A12D10D.3000504@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2009 at 05:32:29PM +0200, Eric Dumazet wrote:
> Jarek Poplawski a =E9crit :
> > On 19-05-2009 04:35, Stephen Hemminger wrote:
> >> Begin forwarded message:
> >>
> >> Date: Mon, 18 May 2009 14:10:20 GMT
> >> From: bugzilla-daemon@bugzilla.kernel.org
> >> To: shemminger@linux-foundation.org
> >> Subject: [Bug 13339] New: rtable leak in ipv4/route.c
> >>
> >>
> >> http://bugzilla.kernel.org/show_bug.cgi?id=3D13339
> > ...
> >> 2.6.29 patch has introduced flexible route cache rebuilding. Unfor=
tunately the
> >> patch has at least one critical flaw, and another problem.
> >>
> >> rt_intern_hash calculates rthi pointer, which is later used for ne=
w entry
> >> insertion. The same loop calculates cand pointer which is used to =
clean the
> >> list. If the pointers are the same, rtable leak occurs, as first t=
he cand is
> >> removed then the new entry is appended to it.
> >>
> >> This leak leads to unregister_netdevice problem (usage count > 0).
> >>
> >> Another problem of the patch is that it tries to insert the entrie=
s in certain
> >> order, to facilitate counting of entries distinct by all but QoS p=
arameters.
> >> Unfortunately, referencing an existing rtable entry moves it to li=
st beginning,
> >> to speed up further lookups, so the carefully built order is destr=
oyed.
>=20
> We could change rt_check_expire() to be smarter and handle any order =
in chains.
>=20
> This would let rt_intern_hash() be simpler.
>=20
> As its a more performance critical path, all would be good :)
>=20
> >>
> >> For the first problem the simplest patch it to set rthi=3D0 when r=
thi=3D=3Dcand, but
> >> it will also destroy the ordering.
> >=20
> > I think fixing this bug fast is more important than this
> > ordering or counting. Could you send your patch proposal?
> >=20
>=20
> Here is mine, only compiled, not tested yet.
>=20
> All credits for Stephen for doing the analysis of course :)

- All credits for Stephen for doing the analysis of course :)
+ All credits for Alexander V. Lukyanov for doing the analysis of cours=
e :)

Jarek P.
