From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC nf-next-2.6] conntrack: per cpu nf_conntrack_untracked
Date: Fri, 04 Jun 2010 13:40:26 +0200
Message-ID: <4C08E62A.9020607@trash.net>
References: <1271941082.14501.189.camel@jdb-workstation>	 <q2h412e6f7f1004220613m488c2ee4r6d24a8d1e65997d4@mail.gmail.com>	 <4BD04C74.9020402@trash.net> <1271946961.7895.5665.camel@edumazet-laptop>	 <1271948029.7895.5707.camel@edumazet-laptop>	 <20100422155123.GA2524@linux.vnet.ibm.com>	 <1271952128.7895.5851.camel@edumazet-laptop>	 <Pine.LNX.4.64.1004222213290.10919@ask.diku.dk>	 <1272056237.4599.7.camel@edumazet-laptop>	 <Pine.LNX.4.64.1004241219280.32071@ask.diku.dk>	 <1272139861.20714.525.camel@edumazet-laptop>	 <1272292568.13192.43.camel@jdb-workstation>	 <1275340896.2478.26.camel@edumazet-laptop>	 <AANLkTikw3uonDB4nPXg8FVFN_07F_wq0SA_ayyAHL6VM@mail.gmail.com>	 <1275368732.2478.88.camel@edumazet-laptop>  <4C04DE73.6050605@trash.net>	 <1275388310.2738.2.camel@edumazet-laptop>  <4C04E3E
 2.7020209@trash.net> <1275409203.2738.227.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netfilter Developers <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49114 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751344Ab0FDLk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 07:40:29 -0400
In-Reply-To: <1275409203.2738.227.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le mardi 01 juin 2010 =E0 12:41 +0200, Patrick McHardy a =E9crit :
>=20
>>> BTW, I notice nf_conntrack_untracked is incorrectly annotated
>>> '__read_mostly'.
>>>
>>> It can be written very often :(
>>>
>>> Should'nt we special case it and let be really const ?
>> That would need quite a bit of special-casing to avoid touching
>> the reference counts. So far this is completely hidden, so I'd
>> say it just shouldn't be marked __read_mostly. Alternatively we
>> can make "untracked" a nfctinfo state.
>=20
> I tried this suggestion, (a new IP_CT_UNTRACKED ctinfo), over a per_c=
pu
> untracked ct, but its a bit hard.
>=20
> For example, I cannot find a way to change ctnetlink_conntrack_event(=
) :
>=20
> 	if (ct =3D=3D &nf_conntrack_untracked)
> 		return 0;
>=20
> Maybe this piece of code is not necessary, we should not come here
> anyway, or it means several packets could store events for this (shar=
ed)
> ct ?

We probably shouldn't be reaching that code since that would mean
that we previously did modifications to the untracked conntrack.
But a quick audit shows that f.i. xt_connmark will do just that.

> Obviously, an IPS_UNTRACKED bit would be much easier to implement.
> Would it be acceptable ?

That also would be fine. However the main idea behind using a nfctinfo
bit was that we wouldn't need the untracked conntrack anymore at all.
But I guess a per-cpu untrack conntrack would already be an improvement
over the current situation.
