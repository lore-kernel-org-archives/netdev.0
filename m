From: Eric Garver <e@erig.me>
Subject: Re: [PATCH net-next 1/2] openvswitch: remove nonreachable code in
 vlan parsing
Date: Tue, 4 Oct 2016 20:06:18 -0400
Message-ID: <20161005000618.GN25403@egarver>
References: <cover.1475583870.git.jbenc@redhat.com>
 <cfc3e476bc30c1e15506e80955bf43563de3c16c.1475583870.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, pravin shelar <pshelar@ovn.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41876 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751527AbcJEAGU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Oct 2016 20:06:20 -0400
Content-Disposition: inline
In-Reply-To: <cfc3e476bc30c1e15506e80955bf43563de3c16c.1475583870.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

On Tue, Oct 04, 2016 at 02:30:01PM +0200, Jiri Benc wrote:
> It can never happen that there's a vlan tag in the packet but not in
> skb->vlan_tci. This is ensured in __netif_receive_skb_core and honored by
> skb_vlan_push and skb_vlan_pop. The code dealing with such case is a dead
> code.
>

This code is also called for packets passed back down from userspace
(after the flow key miss and upcall). So it does happen that we have a
skb without skb->vlan_tci set.

See the chain:
ovs_packet_cmd_execute()
  ovs_flow_key_extract_userspace()
    key_extract()
      parse_vlan()

> Moreover, the likely() statement around skb_vlan_tag_present is bogus. This
> code is called whenever flow key is being extracted from the packet. The
> packet may be as likely vlan tagged as not.
> 

I guess the unlikely scenario is the one I mention above.
