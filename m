From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 1/2] openvswitch: remove nonreachable code in
 vlan parsing
Date: Wed, 5 Oct 2016 14:53:49 +0200
Message-ID: <20161005145349.51509e00@griffin>
References: <cover.1475583870.git.jbenc@redhat.com>
        <cfc3e476bc30c1e15506e80955bf43563de3c16c.1475583870.git.jbenc@redhat.com>
        <20161005000618.GN25403@egarver>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pravin shelar <pshelar@ovn.org>
To: Eric Garver <e@erig.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56226 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752022AbcJEMxy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Oct 2016 08:53:54 -0400
In-Reply-To: <20161005000618.GN25403@egarver>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 4 Oct 2016 20:06:18 -0400, Eric Garver wrote:
> This code is also called for packets passed back down from userspace
> (after the flow key miss and upcall). So it does happen that we have a
> skb without skb->vlan_tci set.

That sucks. The vlan handling should be really consistent, Jiri Pirko
and others put great effort to unify it in the stack, we should make
use of that effort.

I'll respin this patchset and add a patch to make the vlan handling
consistent.

> See the chain:
> ovs_packet_cmd_execute()
>   ovs_flow_key_extract_userspace()
>     key_extract()
>       parse_vlan()
> 
> > Moreover, the likely() statement around skb_vlan_tag_present is bogus. This
> > code is called whenever flow key is being extracted from the packet. The
> > packet may be as likely vlan tagged as not.
> 
> I guess the unlikely scenario is the one I mention above.

But it's wrong. It's also called via

ovs_vport_receive()
  ovs_flow_key_extract()
    key_extract()
      parse_vlan()

and in that path, both cases (vlan vs. non-vlan) are equally possible.

 Jiri
