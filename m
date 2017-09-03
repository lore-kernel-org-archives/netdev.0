From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [pull request][net-next 0/3] Mellanox, mlx5 GRE tunnel offloads
Date: Sun, 03 Sep 2017 03:32:29 +0200
Message-ID: <1504402349.3299394.1093467800.72B91372@webmail.messagingengine.com>
References: <20170830230409.15176-1-saeedm@mellanox.com>
 <87fuc7ong0.fsf@stressinduktion.org>
 <CALzJLG-u3k11LYFXtZQKT5cvn-iJ4FehBUgkhCHT5Z7XMsMkpA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:38151 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752806AbdICBc3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2017 21:32:29 -0400
In-Reply-To: <CALzJLG-u3k11LYFXtZQKT5cvn-iJ4FehBUgkhCHT5Z7XMsMkpA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Saeed,

On Sun, Sep 3, 2017, at 01:01, Saeed Mahameed wrote:
> On Thu, Aug 31, 2017 at 6:51 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > Saeed Mahameed <saeedm@mellanox.com> writes:
> >
> >> The first patch from Gal and Ariel provides the mlx5 driver support for
> >> ConnectX capability to perform IP version identification and matching in
> >> order to distinguish between IPv4 and IPv6 without the need to specify the
> >> encapsulation type, thus perform RSS in MPLS automatically without
> >> specifying MPLS ethertyoe. This patch will also serve for inner GRE IPv4/6
> >> classification for inner GRE RSS.
> >
> > I don't think this is legal at all or did I misunderstood something?
> >
> > <https://tools.ietf.org/html/rfc3032#section-2.2>
> 
> It seems you misunderstood the cover letter.  The HW will still
> identify MPLS (IPv4/IPv6) packets using a new bit we specify in the HW
> steering rules rather than adding new specific rules with  {MPLS
> ethertype} X {IPv4,IPv6} to classify MPLS IPv{4,6} traffic, Same
> functionality a better and general way to approach it.
> Bottom line the hardware is capable of processing MPLS headers and
> perform RSS on the inner packet (IPv4/6) without the need of the
> driver to provide precise steering MPLS rules.

Sorry, I think I am still confused.

I just want to make sure that you don't use the first nibble after the
mpls bottom of stack label in any way as an indicator if that is an IPv4
or IPv6 packet by default. It can be anything. The forward equivalence
class tells the stack which protocol you see.

If you match on the first nibble behind the MPLS bottom of stack label
the '4' or '6' respectively could be part of a MAC address with its
first nibble being 4 or 6, because the particular pseudowire is EoMPLS
and uses no control world.

I wanted to mention it, because with addition of e.g. VPLS this could
cause problems down the road and should at least be controllable? It is
probably better to use Entropy Labels in future.

Thanks,
Hannes
