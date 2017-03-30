From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net] openvswitch: Fix ovs_flow_key_update()
Date: Thu, 30 Mar 2017 20:47:06 +0200
Message-ID: <20170330204706.64616842@griffin>
References: <1490832850-6012-1-git-send-email-yihung.wei@gmail.com>
        <20170330152215.7b4f9703@griffin>
        <CAG1aQhJwShZWAJO_jGEQ_5TaHxpKpfjL0rkpYQSWfn_b9Ua-yg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Joe Stringer <joe@ovn.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Yi-Hung Wei <yihung.wei@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55264 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933891AbdC3SrK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 30 Mar 2017 14:47:10 -0400
In-Reply-To: <CAG1aQhJwShZWAJO_jGEQ_5TaHxpKpfjL0rkpYQSWfn_b9Ua-yg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 30 Mar 2017 11:39:35 -0700, Yi-Hung Wei wrote:
> If we invalidate a flow key of a L3 packet, the flow's mac_proto is like this
> (MAC_PROTO_NONE | SW_FLOW_KEY_INVALID), then key_extract() will
> process the link layer of this L3 packet since mac_proto !=MAC_PROTO_NONE?
> 
> In this case, shall we update key_extract() like this
> static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
> 
>         /* Link layer. */
>         clear_vlan(key);
> -       if (key->mac_proto == MAC_PROTO_NONE) {
> +       if (key->mac_proto & MAC_PROTO_NONE) {

Use ovs_key_mac_proto(key) == MAC_PROTO_NONE.

 Jiri
