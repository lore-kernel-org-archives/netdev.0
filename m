From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] sit: Set skb->protocol properly in
 ipip6_tunnel_xmit()
Date: Mon, 28 Nov 2016 08:53:43 -0800
Message-ID: <1480352023.18162.63.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20161125055017.7053-1-elicooper@gmx.com>
         <20161127130400.4a69ff1b@canb.auug.org.au>
         <20161128.114703.154301432767947066.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, elicooper@gmx.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
        Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33931 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932495AbcK1Qyp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 11:54:45 -0500
Received: by mail-pg0-f66.google.com with SMTP id e9so13571019pgc.1
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 08:54:45 -0800 (PST)
In-Reply-To: <20161128.114703.154301432767947066.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-11-28 at 11:47 -0500, David Miller wrote:
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Sun, 27 Nov 2016 13:04:00 +1100
> 
> > [Just for Dave's information]
> > 
> > On Fri, 25 Nov 2016 13:50:17 +0800 Eli Cooper <elicooper@gmx.com> wrote:
> >>
> >> Similar to commit ae148b085876
> >> ("ip6_tunnel: Update skb->protocol to ETH_P_IPV6 in ip6_tnl_xmit()"),
> >> sit tunnels also need to update skb->protocol; otherwise, TSO/GSO packets
> >> might not be properly segmented, which causes the packets being dropped.
> >> 
> >> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> >> Tested-by: Eli Cooper <elicooper@gmx.com>
> >> Cc: stable@vger.kernel.org
> >> Signed-off-by: Eli Cooper <elicooper@gmx.com>
> > 
> > I tested this patch and it does *not* solve my problem.
> 
> I'm torn on this patch, because it looked exactly like it would solve the
> kind of problem Stephen is running into.
> 
> Even though it doesn't fix his case, it seems correct to me.
> 
> I was wondering if it was also important to set the skb->protocol
> before the call to ip_tunnel_encap() but I couldn't find a dependency.
> 
> In any event I'd like to see some other people review this change
> before I apply it.
> 
> My only other guess for Stephen's problem is somehow the SKB headers
> aren't set up properly for what the GSO engine expects.

Well, mlx4 just works, and uses GSO engine just fine.

So my guess is this is a bug in Intel IGB driver.


Alexander, can you take a look ?

Features for eth0:
rx-checksumming: on
tx-checksumming: on
        tx-checksum-ipv4: off [fixed]
        tx-checksum-ip-generic: on
        tx-checksum-ipv6: off [fixed]
        tx-checksum-fcoe-crc: off [fixed]
        tx-checksum-sctp: on
scatter-gather: on
        tx-scatter-gather: on
        tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: on
        tx-tcp-segmentation: on
        tx-tcp-ecn-segmentation: off [fixed]
        tx-tcp-mangleid-segmentation: off
        tx-tcp6-segmentation: on
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off
receive-hashing: on
highdma: on [fixed]
rx-vlan-filter: on [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: on
tx-gre-csum-segmentation: on
tx-ipxip4-segmentation: on
tx-ipxip6-segmentation: on
tx-udp_tnl-segmentation: on
tx-udp_tnl-csum-segmentation: on
tx-gso-partial: on
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off [fixed]
rx-fcs: off [fixed]
rx-all: off
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off [fixed]
busy-poll: off [fixed]
hw-tc-offload: off [fixed]
