From: "Hubert Sokolowski" <h.sokolowski@wit.edu.pl>
Subject: Re: [PATCH net-next RESEND] net: Do not call ndo_dflt_fdb_dump if
 ndo_fdb_dump is defined.
Date: Wed, 17 Dec 2014 16:18:11 -0000
Message-ID: <e3ac4e3535a18f6dd1cf31030674f91c.squirrel@poczta.wsisiz.edu.pl>
References: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl>
    <54894850.5000603@cumulusnetworks.com>
    <7968540cd0768a770b0c8b29ce41a162.squirrel@poczta.wsisiz.edu.pl>
    <5489D53E.5010603@cumulusnetworks.com>
    <8d4ec5c1ae73c77866a0a154fb528f23.squirrel@poczta.wsisiz.edu.pl>
    <548AD781.5020004@mojatatu.com>
    <4c22a6c452a73b3b77a9a9c8e7f76bcc.squirrel@poczta.wsisiz.edu.pl>
    <548AFD41.3010801@mojatatu.com> <548B4AA4.1020804@gmail.com>
    <548EF05E.6050401@mojatatu.com> <548F80B2.80408@gmail.com>
    <5491A3B5.9070601@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;charset=UTF8
Content-Transfer-Encoding: 8bit
Cc: "John Fastabend" <john.fastabend@gmail.com>,
	"Jamal Hadi Salim" <jhs@mojatatu.com>,
	"Roopa Prabhu" <roopa@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dervish.wsisiz.edu.pl ([213.135.44.54]:22350 "EHLO
	dervish.wsisiz.edu.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979AbaLQQSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 11:18:16 -0500
In-Reply-To: <5491A3B5.9070601@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> I don't think we have to dump uc/mc lists unconditionally.  What we
> want is the lower diver's view of any fdb entries it things are appropriate.
> For simple cards, this becomes equivalent to uc/mc lists.  For smarter cards
> that override the default dumper, it makes sense for them to provide the info.
>

I am very glad to hear that :).

>
> Well, the bridge would have dumped any fdbs that pointer at the bridge
> device (port is NULL) as it's egress port.  Not sure about the vxlan.
> For stacked situations of complex devices this make sense.  For
> instance if you stack vxlan on top of bridge, then from the vxlan
> perspective, we want to see what macs the bridge will forward to the
> vxlan.  Here, the bridge is actually slightly broken as it wouldn't
> actually dump all the pertinent info, but that's more of a bridge problem.

I have just prepared a patch where I dump uc/mc for bridge devices
by looking at (dev->priv_flags & IFF_EBRIDGE), so I have same results
as without my changes. This should satisfy Jamal and Roopa.
I could send it as v3 of my patch along with the results if you are
interested.

>
> -vlad
>


thanks,
Hubert

--
Hubert Sokolowski    Intel Corporation
