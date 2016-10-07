From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next v3 0/6] openvswitch: make vlan handling consistent
Date: Fri, 7 Oct 2016 12:59:08 -0700
Message-ID: <CAOrHB_BTJecjrUsJVzhO4W-edX1V8U7_sn3AHa_Mo+v50n4ycQ@mail.gmail.com>
References: <cover.1475855896.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Garver <e@erig.me>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:44956 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932441AbcJGT7O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2016 15:59:14 -0400
Received: from mfilter19-d.gandi.net (mfilter19-d.gandi.net [217.70.178.147])
        by relay5-d.mail.gandi.net (Postfix) with ESMTP id A1E9541C07E
        for <netdev@vger.kernel.org>; Fri,  7 Oct 2016 21:59:11 +0200 (CEST)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
        by mfilter19-d.gandi.net (mfilter19-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id 2WDRBNehmkkN for <netdev@vger.kernel.org>;
        Fri,  7 Oct 2016 21:59:10 +0200 (CEST)
Received: from mail-it0-f46.google.com (mail-it0-f46.google.com [209.85.214.46])
        (Authenticated sender: pshelar@ovn.org)
        by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 1770141C074
        for <netdev@vger.kernel.org>; Fri,  7 Oct 2016 21:59:09 +0200 (CEST)
Received: by mail-it0-f46.google.com with SMTP id z65so17942940itc.0
        for <netdev@vger.kernel.org>; Fri, 07 Oct 2016 12:59:09 -0700 (PDT)
In-Reply-To: <cover.1475855896.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 7, 2016 at 9:07 AM, Jiri Benc <jbenc@redhat.com> wrote:
> Always keep the first vlan tag "accelerated", i.e. in skb->vlan_tci.
>
> Unfortunately, with all the changes since v2, this patchset no longer has
> the nice deletions > insertions diffstat. I still think it's worth it, as it
> makes things more consistent overall.
>
After looking at the changes, I am not sure about the value. These
patches are making code bit complicated by processing vlan header
twice rather than once in current code.

> Patch 3 is valid on its own. Patch 6 is needed in one form or other; with
> the changes in this set, it's a simple deletion. Otherwise we'd need more
> elaborate checks.
>
As far as patch 6 is concerned I think we could do MTU checks similar
to the rest of networking stack (for example is_skb_forwardable()).
That would simplify things here.


> Jiri Benc (6):
>   openvswitch: make skb modifiable in ovs_flow_key_extract*
>   openvswitch: normalize vlan rx path
>   openvswitch: add NETIF_F_HW_VLAN_STAG_TX to internal dev
>   openvswitch: keep vlan tag accelerated on internal device
>   openvswitch: remove unreachable code in vlan parsing
>   openvswitch: fix vlan subtraction from packet length
>
>  net/openvswitch/datapath.c           |  9 ++--
>  net/openvswitch/flow.c               | 83 ++++++++++++++++++++++++------------
>  net/openvswitch/flow.h               | 14 +++---
>  net/openvswitch/vport-internal_dev.c |  9 +++-
>  net/openvswitch/vport.c              | 18 +++-----
>  5 files changed, 83 insertions(+), 50 deletions(-)
>
> --
> 1.8.3.1
>
