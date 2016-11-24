From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 2/2] openvswitch: Fix skb->protocol for vlan
 frames.
Date: Thu, 24 Nov 2016 17:10:46 +0100
Message-ID: <20161124171046.7eb0e287@griffin>
References: <1479874174-75329-1-git-send-email-jarno@ovn.org>
        <1479874174-75329-2-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53894 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757226AbcKXQKu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Nov 2016 11:10:50 -0500
In-Reply-To: <1479874174-75329-2-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Nov 2016 20:09:34 -0800, Jarno Rajahalme wrote:
> Do not set skb->protocol to be the ethertype of the L3 header, unless
> the packet only has the L3 header.  For a non-hardware offloaded VLAN
> frame skb->protocol needs to be one of the VLAN ethertypes.
> 
> Any VLAN offloading is undone on the OVS netlink interface.  Due to
> this all VLAN packets sent to openvswitch module from userspace are
> non-offloaded.

This is exactly why I wanted to always accelerate the vlan tag, the
same way it is done in other parts of the networking stack: to prevent
all those weird corner cases.

Looks to me this is the only real way forward.

This patch is wrong, it would leave skb->protocol as ETH_P_TEB for L2
frames received via ARPHRD_NONE interface.

 Jiri
