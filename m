From: Joe Perches <joe@perches.com>
Subject: Re: use-after-free in sctp_do_sm
Date: Thu, 03 Dec 2015 12:24:06 -0800
Message-ID: <1449174246.12092.8.camel@perches.com>
References: <CACT4Y+ZnWRZfQC25uW=GXHAJB=GX0L6tJQUy43P6WNR3=hwT8Q@mail.gmail.com>
	 <20151203130525.GB4164@mrl.redhat.com>
	 <CACT4Y+ZMshfGvb81VhCGuZzbSec2sCBaJUNFb1QQ-ccyH9BPkQ@mail.gmail.com>
	 <CANn89iKEv-q6EFi1eX+Hk_2+jNfZ0ayUqUn_Fh1U7RTs9xjdXg@mail.gmail.com>
	 <CACT4Y+bgeqS05zqkAHkxzAP7fuvFSkeEybwDTizw6Gp8KK28Fw@mail.gmail.com>
	 <CANn89i+d=mTJ-hAhhgPXsZPGAkQdECxRdbkeRLfozRq8i9Ms+g@mail.gmail.com>
	 <CACT4Y+YJe-OJj9q1Kr5-_ApDt1UBKLjTRxhP62EHtEAwZt5vXw@mail.gmail.com>
	 <f7twpsvgyar.fsf@aconole.bos.csb> <566098BD.6010803@akamai.com>
	 <1449172984.12092.0.camel@perches.com> <5660A1A7.3080301@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <edumazet@google.com>,
	syzkaller <syzkaller@googlegroups.com>,
	Vladislav Yasevich <vyasevich@gmail.com>,
	linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Jason Baron <jbaron@akamai.com>, Aaron Conole <aconole@redhat.com>,
	Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0160.hostedemail.com ([216.40.44.160]:35541 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753739AbbLCUYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 15:24:11 -0500
In-Reply-To: <5660A1A7.3080301@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-12-03 at 15:10 -0500, Jason Baron wrote:
> On 12/03/2015 03:03 PM, Joe Perches wrote:
> > On Thu, 2015-12-03 at 14:32 -0500, Jason Baron wrote:
> > > On 12/03/2015 01:52 PM, Aaron Conole wrote:
> > > > I think that as a minimum, the following patch should be evalut=
ed,
> > > > but am unsure to whom I should submit it (after I test):
> > []
> > > Agreed - the intention here is certainly to have no side effects.=
 It
> > > looks like 'no_printk()' is used in quite a few other places that=
 would
> > > benefit from this change. So we probably want a generic
> > > 'really_no_printk()' macro.
> >=20
> > https://lkml.org/lkml/2012/6/17/231
>=20
> I don't see this in the tree.

It never got applied.

> Also maybe we should just convert
> no_printk() to do what your 'eliminated_printk()'.

Some of them at least.

> So we can convert all users with this change?

I don't think so, I think there are some
function evaluation/side effects that are
required. =A0I believe some do hardware I/O.

It'd be good to at least isolate them.

I'm not sure how to find them via some
automated tool/mechanism though.

I asked Julia Lawall about it once in this
thread:  https://lkml.org/lkml/2014/12/3/696
