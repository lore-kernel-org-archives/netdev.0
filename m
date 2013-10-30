From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH v2 net-next] net: introduce gro_frag_list_enable sysctl
Date: Wed, 30 Oct 2013 10:39:00 -0700
Message-ID: <CAPshTCg8j-y6fGfh0tRMir34-Lzy77qyzibvwjMSMpR0Rr1rsA@mail.gmail.com>
References: <1383059555.5464.33.camel@edumazet-glaptop.roam.corp.google.com>
	<20131029.194446.2215574000648693370.davem@davemloft.net>
	<1383094428.4857.16.camel@edumazet-glaptop.roam.corp.google.com>
	<20131029.220253.1263087684709722001.davem@davemloft.net>
	<1383106012.4857.26.camel@edumazet-glaptop.roam.corp.google.com>
	<20131030040818.GB2755@gondor.apana.org.au>
	<1383106577.4857.30.camel@edumazet-glaptop.roam.corp.google.com>
	<20131030041959.GA3162@gondor.apana.org.au>
	<1383107681.4857.33.camel@edumazet-glaptop.roam.corp.google.com>
	<20131030044212.GA3364@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Michael Dalton <mwdalton@google.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f169.google.com ([209.85.128.169]:34861 "EHLO
	mail-ve0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751806Ab3J3RjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 13:39:01 -0400
Received: by mail-ve0-f169.google.com with SMTP id c14so1275280vea.0
        for <netdev@vger.kernel.org>; Wed, 30 Oct 2013 10:39:00 -0700 (PDT)
In-Reply-To: <20131030044212.GA3364@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 29, 2013 at 9:42 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
>
> On Tue, Oct 29, 2013 at 09:34:41PM -0700, Eric Dumazet wrote:
> >
> > What matters ?
> >
> > GRO ?
>
> What matters is that you should not treat the forwarding case
> separately from the host case.
>
> For virtualisation the host case looks exactly like the forwarding
> case.


Not sure I agree - there are two different "forwarding" cases - forwarding
to another physical NIC (to go out to the wire hence need to do GSO),
and (for virtualization) forwarding to a virtual NIC and consumed internally
(e.g., VM). For the latter we should strive to push GSO pkts all the way
to the VM stack w/o breaking them up. So for virtualization GRO is all
goodness but not sure about the regular forwarding path. (From the
perf perspective it boils down to if the cost of GSO/GRO will offset
the benefit of GRO. Sure if one manages to get the cost close to zero
than there is not reason to leave GRO always on. But it's still a big if for
now.)

Best,

Jerry

>
>
> IOW, if having a 64KB packet matters for the host, then it matters
> for forwarding as well.
>
> > Before my patch, GRO packets were 17 MSS, and nobody complained packets
> > were too small, so what are you saying exactly ?
>
> I'm not criticsing your mega-GRO patch at all.  That one is great
> and means that we'll get aggregated packets up to 64K.  What we need
> to do is just to patch up the GSO code so that it can handle these
> mega-packets properly.
>
> Cheers,
> --
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
