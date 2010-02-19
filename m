From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel stack  trace using conntrack
Date: Fri, 19 Feb 2010 13:33:44 +0100
Message-ID: <1266582824.3136.1.camel@edumazet-laptop>
References: <7EF5DBE4C76A7B4DA655334E9F2BFD26CED7BC8D04@FRSPX100.fr01.awl.atosorigin.net>
	 <1266313889.3045.1.camel@edumazet-laptop>
	 <7EF5DBE4C76A7B4DA655334E9F2BFD26CED7BC8D54@FRSPX100.fr01.awl.atosorigin.net>
	 <1266318928.3045.38.camel@edumazet-laptop>  <4B7A9E95.103@netfilter.org>
	 <1266327917.3045.55.camel@edumazet-laptop>
	 <7EF5DBE4C76A7B4DA655334E9F2BFD26CED7BC905D@FRSPX100.fr01.awl.atosorigin.net>
	 <4B7D17CE.6010805@trash.net> <4B7D1E32.6000705@netfilter.org>
	 <4B7D215A.6060400@trash.net> <4B7D3022.9030405@netfilter.org>
	 <4B7D306F.9060808@trash.net>  <4B7DF4DC.4000502@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Ramblewski David <David.Ramblewski@atosorigin.com>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:58532 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751312Ab0BSMd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 07:33:57 -0500
In-Reply-To: <4B7DF4DC.4000502@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 19 f=C3=A9vrier 2010 =C3=A0 03:18 +0100, Pablo Neira Ayuso =
a =C3=A9crit :
> Patrick McHardy wrote:
> > Pablo Neira Ayuso wrote:
> >> Patrick McHardy wrote:
> >>>>> Pablo, please let me know whether you want me to apply this.
> >>>> ctnetlink_change_helper() also calls nf_ct_ext_add() for conntra=
cks that
> >>>> are confirmed (in case of a helper update for an existing conntr=
ack).
> >>>> That would also trigger the assertion. If we want to support hel=
per
> >>>> assignation via ctnetlink for existing conntracks, we will need =
to add
> >>>> locking to the conntrack extension infrastructure to avoid races=
=2E
> >>>>
> >>>> I don't see a clear solution for this yet.
> >>> I see, this is indeed a problem. Since the helper is known at the
> >>> first event, we could restrict this to only allow manual assignme=
nt
> >>> for newly created conntracks. Most helpers probably can't properl=
y
> >>> cope with connections not seen from the beginning anyways.
> >> Indeed, changing the helper in the middle of the road doesn't make=
 too
> >> much sense to me either. I can send you a patch for this along tod=
ay,
> >> I'll find some spare time to do it.
> >=20
> > Great, thanks Pablo.
>=20
> I have slightly tested the following patch here. I think it should fi=
x
> the problem.
>=20
> We can revisit ctnetlink_change_helper() later, I think there's some
> code there that can be refactorized.
>=20
> Let me know if you're OK with it.

I sucessfuly tested your patch Pablo, thanks.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>



