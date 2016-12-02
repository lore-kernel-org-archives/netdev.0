From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH v3 net-next 2/3] openvswitch: Use is_skb_forwardable()
 for length check.
Date: Fri, 2 Dec 2016 10:25:09 +0100
Message-ID: <20161202102509.065df1e8@griffin>
References: <1480462253-114713-1-git-send-email-jarno@ovn.org>
        <1480462253-114713-2-git-send-email-jarno@ovn.org>
        <20161130145159.3cee7ba4@griffin>
        <CAOrHB_BEQBbvDa2W0dJmmANsjZEiwx7GbTxo-7yirDB=5d9cqQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarno Rajahalme <jarno@ovn.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Garver <e@erig.me>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48702 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758611AbcLBJZN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 04:25:13 -0500
In-Reply-To: <CAOrHB_BEQBbvDa2W0dJmmANsjZEiwx7GbTxo-7yirDB=5d9cqQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 1 Dec 2016 11:50:00 -0800, Pravin Shelar wrote:
> This is not changing any behavior compared to current OVS vlan checks.
> Single vlan header is not considered for MTU check.

It is changing it.

Consider the case when there's an interface with MTU 1500 forwarding to
an interface with MTU 1496. Obviously, full-sized vlan frames
ingressing on the first interface are not forwardable to the second
one. Yet, if the vlan tag is accelerated (and thus not counted in
skb->len), is_skb_forwardable happily returns true because of the check

        len = dev->mtu + dev->hard_header_len + VLAN_HLEN;
        if (skb->len <= len)

 Jiri
