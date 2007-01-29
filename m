From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address Detection
Date: Mon, 29 Jan 2007 11:34:47 -0500
Message-ID: <20070129163447.GB21938@hmsreliant.homelinux.net>
References: <20070125133340.GA8891@hmsreliant.homelinux.net> <45B8E60B.7080809@hp.com> <20070125194500.GB8891@hmsreliant.homelinux.net> <20070126.091331.22638713.yoshfuji@linux-ipv6.org> <20070126191817.GC15916@hmsreliant.homelinux.net> <45BA6478.4020304@hp.com> <20070126213524.GD15916@hmsreliant.homelinux.net> <45BA75D1.6040005@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>, sri@us.ibm.com, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, netdev@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3436 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751963AbXA2Qks (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jan 2007 11:40:48 -0500
Content-Disposition: inline
In-Reply-To: <45BA75D1.6040005@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 26, 2007 at 04:42:41PM -0500, Vlad Yasevich wrote:
> Neil Horman wrote:
> > On Fri, Jan 26, 2007 at 03:28:40PM -0500, Vlad Yasevich wrote:
> >> Hi Neil
> >>
> >> Neil Horman wrote:
> >>> On Fri, Jan 26, 2007 at 09:13:31AM +0900, YOSHIFUJI Hideaki / =E5=
=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> >>>> In article <20070125194500.GB8891@hmsreliant.homelinux.net> (at =
Thu, 25 Jan 2007 14:45:00 -0500), Neil Horman <nhorman@tuxdriver.com> s=
ays:
> >>>
> >>> New patch attached with most of your suggestions incorporated.  I=
've a few
> >>> comments mixed in for some of the suggestions that I think need f=
urther
> >>> discussion
> >>>
> >>>> If optimistic_dad is disabled, flags should be IFA_F_TEMPORARY,
> >>>> not IFA_F_TEMPORARY|IFA_F_OPTIMISTIC.
> >>>>
> >>>> Another idea is to use IFA_F_OPTIMISTIC not
> >>>> IFA_F_OPTIMISTIC|IFA_F_TENTATIVE until the DAD has been finished=
=2E
> >>>>
> >>> I'm currently setting the OPTIMISTIC flag in every location that =
its possibly
> >>> needed, and then clearing it in addrconf_dad_start if that interf=
ace is not
> >>> participating in optimistic dad.  I do this because the RFC in se=
ction 3.1
> >>> indicates that manually configured addresses should not set the o=
ptimistic flag.
> >>> If I removed the OPTIMISTIC flag from the locations it gets set i=
n the patch and
> >>> then only set it for participating interfaces in addrconf_dad_sta=
rt, I would
> >>> need to have some way to tell if the address in question was manu=
ally configured
> >>> (to avoid setting it in that case).  At present I see no clear wa=
y to do that,
> >>> but if you have a suggestion, I'll happily change this around.
> >> One suggestiong/question:
> >>
> >> Instead of clearing the OPTIMISTIC flag in addrconf_dad_start(), w=
ouldn't it be better
> >> to simply not set the flag in ipv6_add_addr()?  Just mask that fla=
g from the 'flags'
> >> argument passed to that function when conditions are right.
> >>
> > Doh!  Sometimes I don't just think straight.  Yes, as long as ipv6_=
add_addr is
> > only for adding static addresses (which it pretty clearly is), that=
 would work
> > much better.  I'll fix it up and repost on monday.
> >=20
> > Don't suppose you have any thoughts on how to solve the "send to de=
fault router"
> > problem, do you?
> >=20
>=20
> Still trying to figure how the routing side works. sorry....
>=20
> -vlad
I've got your flag changes made, but I'm holding off on reposting for a=
 bit.
Dave M. just gave me some advice on how best to handle the default rout=
er case.
Trying to understand the routing code and integrate that before I repos=
t.

Thanks
Neil

