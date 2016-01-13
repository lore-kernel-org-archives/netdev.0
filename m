From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] phonet: properly unshare skbs in phonet_rcv()
Date: Wed, 13 Jan 2016 07:07:32 -0800
Message-ID: <1452697652.1223.63.camel@edumazet-glaptop2.roam.corp.google.com>
References: <568EA671.7000502@gmail.com> <56929985.3020502@gmail.com>
	 <1452457610.16445.13.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5694188F.80907@gmail.com>
	 <CAO7SqHA9dNUDG+pYJoQvipE_ErM4Bgo0_o9er_OLxZLDgNVJ8Q@mail.gmail.com>
	 <56944DFA.4050002@gmail.com>
	 <1452560786.1223.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAO7SqHC+fTCyNd8ukSH4tJ1qPvAYzMGSfhrzXmMn0NLve6NTQA@mail.gmail.com>
	 <1452565288.1223.10.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1452565515.1223.11.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5694A840.8030900@gmail.com>
	 <1452608377.1223.13.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1452617880.1223.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <ba49c1524db476eab37647078cfeddcc@roundcube.remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont <remi@remlab.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35937 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757214AbcAMPHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2016 10:07:34 -0500
Received: by mail-pa0-f47.google.com with SMTP id yy13so267083809pab.3
        for <netdev@vger.kernel.org>; Wed, 13 Jan 2016 07:07:33 -0800 (PST)
In-Reply-To: <ba49c1524db476eab37647078cfeddcc@roundcube.remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-01-13 at 14:26 +0200, R=C3=A9mi Denis-Courmont wrote:
> Le 2016-01-12 18:58, Eric Dumazet a =C3=A9crit :
> > From: Eric Dumazet <edumazet@google.com>
> >
> > Ivaylo Dimitrov reported a regression caused by commit 7866a621043f
> > ("dev: add per net_device packet type chains").
> >
> > skb->dev becomes NULL and we crash in __netif_receive_skb_core().
> >
> > Before above commit, different kind of bugs or corruptions could=20
> > happen
> > without major crash.
>=20
> Hmm... was that always a problem then, or did it get introduced=20
> earlier? I thought it was impossible for skb to be shared on PF-recv=20
> callback way back.

Always been a problem.

Use tcpdump and you risk use after free.

Or simply panics if skb->head needs to be expanded.

Other relevant commits to explain this :

044453b3efdc90bdd5feffe74b99d95dec70ac43 arp: fix possible crash in
arp_rcv()

b30532515f0a62bfe17207ab00883dd262497006 bonding: Ensure that we unshar=
e
skbs prior to calling pskb_may_pull
