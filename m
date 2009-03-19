From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCHv3] netns: oops in ip[6]_frag_reasm incrementing stats
Date: Thu, 19 Mar 2009 22:54:28 +0100
Message-ID: <20090319215428.GA2714@ami.dom.local>
References: <49BFAB7C.1020503@dti2.net> <20090318072658.GA4799@ff.dom.local> <20090318.232651.99085030.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jorge@dti2.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:49217 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756425AbZCSVzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 17:55:20 -0400
Received: by fxm2 with SMTP id 2so691878fxm.37
        for <netdev@vger.kernel.org>; Thu, 19 Mar 2009 14:55:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090318.232651.99085030.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 18, 2009 at 11:26:51PM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Wed, 18 Mar 2009 07:26:58 +0000
>=20
> > On 17-03-2009 14:54, Jorge Boncompte [DTI2] wrote:
> > > Jarek Poplawski escribi=F3:
> > >> On Tue, Mar 17, 2009 at 12:55:42PM +0100, Jorge Boncompte [DTI2]=
 wrote:
> > >>> dev can be NULL in ip[6]_frag_reasm for skb's coming from RAW s=
ockets.
> > >>>
> > >>> Quagga's OSPFD sends fragmented packets on a RAW socket, when n=
etfilter
> > >>> conntrack reassembles them on the OUTPUT path you hit this code=
 path.
> > >>>
> > >>> You can test it with something like "hping2 -0 -d 2000 -f AA.BB=
=2ECC.DD"
> > >>>
> > >>> Changes from v2: (address comments from Jarek Poplawski)
> > >>> 	- Patch reworked to get the net pointer with container_of()
> > >>> 	  instead of passing it to function calls.
> > >>> 	- Fix IPv6 code
> > >>> Changes from v1:
> > >>> 	- Fixed description
> > >> I guess David will be interested only with the final state of ch=
anges,
> > >> so v1 & v2 are not necessary here...
> > >>
> > >> Anyway, ipv4 looks OK to me, but ipv6 looks like something is
> > >> different:
> > >>> +	IP6_INC_STATS_BH(net, __in6_dev_get(dev), IPSTATS_MIB_REASMFA=
ILS);
> > >> It still depends on dev !=3D NULL in __in6_dev_get(). I see ther=
e
> > >> is also used skb->dst for similar things in ip6_frag_queue(), so=
 I
> > >> don't know: it needs rethinking, and maybe these patches should =
be
> > >> separated if you prefer.
> > >=20
> > > 	Not my day! :-) I should not look at code at 2 am and write patc=
hes
> > > the day after, I confused _idev and idev in the check for !=3D NU=
LL in _DEVINC.
> > >=20
> > > 	I think this bug was first introduced by patch "[IPV6]: Per-inte=
rface
> > > statistics support." from YOSHIFUJI Hideaki on Nov 4, 2006.
> > >=20
> > > 	If someone with more knowledge could confirm that using somethin=
g like...
> > >=20
> > > "(skb->dev ? skb->dev : skb->dst->dev)"
> > >=20
> > > ... here is fine I'll redo this part and resend. I do not have an=
 IPv6 setup where
> > > I can test this.
> > >=20
> >=20
> > skb->dst->dev is used in ip6_frag_queue anyway, so it shouldn't be
> > worse if you do this similarly in ip6_frag_reasm. If you send it as
> > a separate patch, and write it's not tested, David will decide if h=
e
> > wants it. Otherwise you can resend this ipv4 patch only.
>=20
> Netfilter on ipv6 handles reassembly differently and in a way
> that won't result in dev being NULL here.
>=20
> I've applied Jorge's patch, thanks everyone.

My proposal is to revert the ipv6/reassembly part of this patch yet;
it doesn't fix anything, and the changelog is only misleading if it's
like you said.

Jarek P.
