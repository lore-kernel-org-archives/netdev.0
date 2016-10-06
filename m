From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next v2 2/3] openvswitch: remove unreachable code in
 vlan parsing
Date: Wed, 5 Oct 2016 22:22:13 -0700
Message-ID: <CAOrHB_B+qUf9zOORG6KOUgew3g4hZxPNiexdMTLvtaCuQQy1oQ@mail.gmail.com>
References: <cover.1475672568.git.jbenc@redhat.com> <3b310a67f5a708da69ee3cf617e6cedd52f85842.1475672569.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Garver <e@erig.me>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:34832 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752006AbcJFFWU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2016 01:22:20 -0400
Received: from mfilter24-d.gandi.net (mfilter24-d.gandi.net [217.70.178.152])
        by relay5-d.mail.gandi.net (Postfix) with ESMTP id EB4F541C092
        for <netdev@vger.kernel.org>; Thu,  6 Oct 2016 07:22:17 +0200 (CEST)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
        by mfilter24-d.gandi.net (mfilter24-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id RTTP_5G2qegb for <netdev@vger.kernel.org>;
        Thu,  6 Oct 2016 07:22:15 +0200 (CEST)
Received: from mail-it0-f51.google.com (mail-it0-f51.google.com [209.85.214.51])
        (Authenticated sender: pshelar@ovn.org)
        by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id E409241C080
        for <netdev@vger.kernel.org>; Thu,  6 Oct 2016 07:22:14 +0200 (CEST)
Received: by mail-it0-f51.google.com with SMTP id o21so30953871itb.0
        for <netdev@vger.kernel.org>; Wed, 05 Oct 2016 22:22:14 -0700 (PDT)
In-Reply-To: <3b310a67f5a708da69ee3cf617e6cedd52f85842.1475672569.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 5, 2016 at 6:07 AM, Jiri Benc <jbenc@redhat.com> wrote:
> Now when the first vlan tag is always in skb->vlan_tci, drop code that
> assumed it might not be the case.
>
User can turn off TX vlan offload for OVS internal device that would
allow vlan tagged packet with vlan header on the skb-data. This case
will cause issue here.

We could handle this case by not allowing this configuration.

> This patch also removes the wrong likely() statement around
> skb_vlan_tag_present introduced by 018c1dda5ff1 ("openvswitch: 802.1AD Flow
> handling, actions, vlan parsing, netlink attributes"). This code is called
> whenever flow key is being extracted from the packet, the packet may be as
> likely vlan tagged as not.
>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
