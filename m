From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next v1] gso: Support partial splitting at the
 frag_list pointer
Date: Sat, 27 Aug 2016 10:47:11 +0300
Message-ID: <20160827104711.46f73c12@halley>
References: <20160823052030.GI3735@gauss.secunet.com>
        <CAKgT0UdATK8LUiTQ3sn0nrJTtk9oo29k7CrNdZavsPie_Pte0w@mail.gmail.com>
        <20160824093226.GN3735@gauss.secunet.com>
        <CAKgT0Ucp_M-oCDjvi2Aay=aNBTH=-sGEVxUgq0b=5KrX8j3O9Q@mail.gmail.com>
        <20160825110019.GR3735@gauss.secunet.com>
        <20160826233621.0230ee44@halley>
        <CAKgT0UcYLrx1PzKo6Lw-rHGOj-1wMO2dP-93Brs7EGY-OFR4Gw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        Netdev <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33024 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754721AbcH0ICE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 Aug 2016 04:02:04 -0400
Received: by mail-wm0-f67.google.com with SMTP id o80so2377702wme.0
        for <netdev@vger.kernel.org>; Sat, 27 Aug 2016 01:01:49 -0700 (PDT)
In-Reply-To: <CAKgT0UcYLrx1PzKo6Lw-rHGOj-1wMO2dP-93Brs7EGY-OFR4Gw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, 26 Aug 2016 13:45:56 -0700 Alexander Duyck <alexander.duyck@gmail.com> wrote:
> > However, if TSO is off, but GSO is on, who takes care of further
> > splitting these skbs according to their gso_size?  
> 
> I believe the patch resolves it via the net_gso_ok check.  This is
> used to verify if the lower device could segment it if we split out
> the buffers from skb->frag_list.

Thanks, got it.

> > And another question:
> > Can this be utilized in any way to solve the problem described in [1] ?
> >
> > [1] https://patchwork.ozlabs.org/patch/661419/  
> 
> I don't think so.  This solution is to only do part of the software
> offload and still make use of an existing hardware offload.

Sorry, I wasn't too clear.

When attempting to reduce gso_size in order to avoid
segmentation+fragmentation, problem I'm hitting is:
  http://lists.openwall.net/netdev/2016/08/25/35

Actually, the idea of yours hinted me to a new direction, will pursue
that.

Thanks,
Shmulik
