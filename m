From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/tunnel: set inner protocol in network gro hooks
Date: Thu, 09 Mar 2017 13:20:07 -0800 (PST)
Message-ID: <20170309.132007.2251976782084375348.davem@davemloft.net>
References: <4cfee33672b0fd2b1db66d603574a93e76e118b3.1488907722.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.duyck@gmail.com,
        tom@herbertland.com
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44490 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750781AbdCIVUK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 16:20:10 -0500
In-Reply-To: <4cfee33672b0fd2b1db66d603574a93e76e118b3.1488907722.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Tue,  7 Mar 2017 18:33:31 +0100

> The gso code of several tunnels type (gre and udp tunnels)
> takes for granted that the skb->inner_protocol is properly
> initialized and drops the packet elsewhere.
> 
> On the forwarding path no one is initializing such field,
> so gro encapsulated packets are dropped on forward.
> 
> Since commit 38720352412a ("gre: Use inner_proto to obtain
> inner header protocol"), this can be reproduced when the
> encapsulated packets use gre as the tunneling protocol.
> 
> The issue happens also with vxlan and geneve tunnels since
> commit 8bce6d7d0d1e ("udp: Generalize skb_udp_segment"), if the
> forwarding host's ingress nic has h/w offload for such tunnel
> and a vxlan/geneve device is configured on top of it, regardless
> of the configured peer address and vni.
> 
> To address the issue, this change initialize the inner_protocol
> field for encapsulated packets in both ipv4 and ipv6 gro complete
> callbacks.
> 
> Fixes: 38720352412a ("gre: Use inner_proto to obtain inner header protocol")
> Fixes: 8bce6d7d0d1e ("udp: Generalize skb_udp_segment")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied and queued up for -stable.
