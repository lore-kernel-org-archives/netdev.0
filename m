From: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH net-next] {selinux, af_key} Rework pfkey_sadb2xfrm_user_sec_ctx
Date: Thu, 17 Oct 2013 21:18:40 -0400
Message-ID: <62825117.jOccj7YDuu@sifl>
References: <1381904114-29556-1-git-send-email-fan.du@windriver.com> <525F3EBD.80406@windriver.com> <20131017095148.GC7660@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fan Du <fan.du@windriver.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f42.google.com ([209.85.216.42]:35609 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291Ab3JRBSp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 21:18:45 -0400
Received: by mail-qa0-f42.google.com with SMTP id w8so222210qac.8
        for <netdev@vger.kernel.org>; Thu, 17 Oct 2013 18:18:44 -0700 (PDT)
In-Reply-To: <20131017095148.GC7660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, October 17, 2013 11:51:48 AM Steffen Klassert wrote:
> On Thu, Oct 17, 2013 at 09:34:53AM +0800, Fan Du wrote:
> > On 2013=E5=B9=B410=E6=9C=8816=E6=97=A5 23:15, Paul Moore wrote:
> > >The fact that you are now changing sadb_x_sec_ctx->sadb_x_sec_len
> > >whenever
> > >pfkey_sadb2xfrm_user_sec_ctx() is called raises an eyebrow.  Can y=
ou
> > >elaborate on why this is not a problem?
> >=20
> > Thanks for your attention, Paul.
> >=20
> > sadb_x_sec_ctx is extra headers passed down from user space, the us=
age of
> > of this data structure falls down to one of pfkey_funcs function on=
ly for
> > one time, more specifically speaking, it's only used by SELINUX for
> > security checking for each operation. In other words, sadb_x_sec_ct=
x
> > involves with a one shot business here. So the original codes seems=
 do a
> > lots of extra job which could easily be avoid using casting operati=
on.
>=20
> Since the selinux people have to live with that change in the fist pl=
ace,
> I'd like to see an ack of one of the selinux maintainers before I tak=
e
> in into ipsec-next, Paul?

Well, my earlier concern over modifying the length field probably isn't=
 a=20
major concern as was pointed out so I could maybe look the other way on=
 that=20
point.  However, while looking a bit closer at the structs and how they=
 are=20
used, I noticed that PFKEY structs are all explicitly packed (sadb_x_se=
c_ctx)=20
and the LSM struct is not (xfrm_user_sec_ctx).  I'm not enough of a com=
piler=20
guru across all the different architectures to know if this is signific=
ant or=20
not given the structure, but it does make me pause.

Any compiler gurus care to weigh in on this?

--=20
paul moore
www.paul-moore.com
