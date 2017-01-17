From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: fq_codel and skb->hash
Date: Tue, 17 Jan 2017 07:14:54 -0800
Message-ID: <1484666094.13165.68.camel@edumazet-glaptop3.roam.corp.google.com>
References: <f9913fca-da16-8620-d237-d7d8d09cced2@cradlepoint.com>
         <1484617489.13165.63.camel@edumazet-glaptop3.roam.corp.google.com>
         <1484620480.13165.65.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALx6S34ugaCqDtE=-4533mNsPgt_T0oHC1CN0-vx_uga+ihLdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Collins <acollins@cradlepoint.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34038 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750741AbdAQPO6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 10:14:58 -0500
Received: by mail-pg0-f68.google.com with SMTP id t6so4158312pgt.1
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 07:14:57 -0800 (PST)
In-Reply-To: <CALx6S34ugaCqDtE=-4533mNsPgt_T0oHC1CN0-vx_uga+ihLdQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-01-16 at 22:18 -0800, Tom Herbert wrote:
> On Mon, Jan 16, 2017 at 6:34 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Mon, 2017-01-16 at 17:44 -0800, Eric Dumazet wrote:
> >> On Mon, 2017-01-16 at 17:04 -0700, Andrew Collins wrote:
> >
> >> >   Is there a better way to manage flow separation in routed+encapsulated traffic?
> >>
> >> Encapsulated traffic is fine, since flow dissector skips encap header(s)
> >> up to the L4 header.
> >>
> >> Problem is about encrypted traffic, since presumably this L4 header is
> >> opaque for flow dissector ;)
> >
> >
> > BTW, how can we make sure skb->hash is populated before IPSEC ?
> >
> > Relying on forwarding, and skb->hash set by a device might be not
> > enough.
> >
> Should we do skb_get_hash upon entry to IPsec?

Right, but that might add overhead in cases we do not need skb->hash
after IPsec . I've heard IPsec is already quite slow :/
