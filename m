From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] net: add recursion limit to GRO
Date: Tue, 11 Oct 2016 03:13:07 +0200
Message-ID: <1476148387.2974887.751853265.25F6FD56@webmail.messagingengine.com>
References: <8fb8ec65c178b4d37951c4538dedc880eef068d4.1476106975.git.sd@queasysnail.net>
 <1476108236.28155.299.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:51997 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752810AbcJKBNP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2016 21:13:15 -0400
In-Reply-To: <1476108236.28155.299.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, Oct 10, 2016, at 16:03, Eric Dumazet wrote:
> On Mon, 2016-10-10 at 15:43 +0200, Sabrina Dubroca wrote:
> > Currently, GRO can do unlimited recursion through the gro_receive
> > handlers.  This was fixed for tunneling protocols by limiting tunnel GRO
> > to one level with encap_mark, but both VLAN and TEB still have this
> > problem.  Thus, the kernel is vulnerable to a stack overflow, if we
> > receive a packet composed entirely of VLAN headers.
> >=20
> > This patch adds a recursion counter to the GRO layer to prevent stack
> > overflow.  When a gro_receive function hits the recursion limit, GRO is
> > aborted for this skb and it is processed normally.
> >=20
> > Thanks to Vladim=C3=ADr Bene=C5=A1 <vbenes@redhat.com> for the initial =
bug report.
>
> [...]
>
> Have you considered using a per cpu counter ?
>=20
> It might be cheaper than using a 4-bit field in skb.
>=20
> Really this counter does not need to be stored in skb. GRO already uses
> way too much space in skb->cb[]

The idea was to use some padding space and not bother with another
static per cpu allocation as long as there is space in the cb, which is
certainly more expensive in terms of memory consumption.

We can add a comment to make future users in gro_cb aware that this can
easily be moved to per cpu allocation if necessary in future?

Bye,
Hannes
