From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Subject: Re: [RFC] networking structure holes
Date: Wed, 1 Nov 2006 23:31:07 -0300
Message-ID: <39e6f6c70611011831m3521599boa5a6a77957d143a8@mail.gmail.com>
References: <20061031203430.GF5319@mandriva.com>
	 <4547BA54.5090709@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:13745 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1750968AbWKBCbJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 21:31:09 -0500
Received: by nf-out-0910.google.com with SMTP id c2so1093116nfe
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2006 18:31:08 -0800 (PST)
To: "Eric Dumazet" <dada1@cosmosbay.com>
In-Reply-To: <4547BA54.5090709@cosmosbay.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/31/06, Eric Dumazet <dada1@cosmosbay.com> wrote:
> Arnaldo Carvalho de Melo a =E9crit :
> > Hi,
> >
> >       I've been working on some DWARF2 utilities and one of them,
> > pahole (Poke-a-Hole) can be used to find holes due to alignment rul=
es
> > in structs, the full output of:
> >
> > [acme@newtoy net-2.6]$ pahole net/ipv4/tcp.o
> >
> >       is available at:
> >
> > http://oops.merseine.nu:81/acme/net.ipv4.tcp.o.pahole
> >
> >       Just to show what we can find with this tool here is the layo=
ut
> > of struct net_device, that barring any cacheline locality optimizat=
ion
> > has 4 bytes to harvest, David, do you think reordering those fields=
 to
> > get 4 byts back is ok?
>
> I just want to bring your attention this net_device structure was re-=
ordered
> (by me :)) so that separate cache lines are used on SMP machines.
>
> If you select CONFIG_SMP , you'll probably notice far more holes. But=
 it was a
> feature, not lazyness.

Thanks for commenting on this case!

> We can probably move some fields, but very carefully :)

Of course, in time I probably will try to combine valgrind's
cachegrind or some new tool using the same principles I used in OSTRA
to find out working sets of struct members to do automatic
"suggestions" on how to reorder structs to avoid holes while keeping
the relevant struct members close together as to exploit cacheline
locality effects, like you do so well manually :-)

- Arnaldo

PS.: While we don't have tools to check out that the holes are not a
problem because we want to exploit cacheline locality effects... what
about some comments on the structs to explain that such holes are not
a problem? :-)
