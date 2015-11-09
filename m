From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] packet: do skb_probe_transport_header when we
 actually have data
Date: Sun, 08 Nov 2015 22:11:21 -0500 (EST)
Message-ID: <20151108.221121.799120546619596684.davem@davemloft.net>
References: <1446922430.17135.13.camel@edumazet-glaptop2.roam.corp.google.com>
	<1446923165.17135.18.camel@edumazet-glaptop2.roam.corp.google.com>
	<563E9874.6040403@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, edumazet@google.com, willemb@google.com,
	tklauser@distanz.ch, netdev@vger.kernel.org, jasowang@redhat.com
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52467 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752455AbbKIDLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2015 22:11:23 -0500
In-Reply-To: <563E9874.6040403@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Sun, 08 Nov 2015 01:33:56 +0100

> Hmm, yeah, on a (only quick) look, it seems this is mostly needed for
> the
> virtio_net related code in packet_snd() / packet_recvmsg(), not
> handled in
> RX/TX ring paths actually.
> 
> $ git grep -n gso_size net/packet/
> net/packet/af_packet.c:2748: if (vnet_hdr.gso_size == 0)
> net/packet/af_packet.c:2825:            skb_shinfo(skb)->gso_size =
> net/packet/af_packet.c:2826: __virtio16_to_cpu(vio_le(),
> vnet_hdr.gso_size);
> net/packet/af_packet.c:3219:                    vnet_hdr.gso_size =
> net/packet/af_packet.c:3220: __cpu_to_virtio16(vio_le(),
> sinfo->gso_size);
> 
> Need to take a closer look on Monday.

I think for complete safety, we need the transport header set for
all SKBs once they hit the device.

I know this is separate from the bugs you are trying to fix, but
let's take care of this in this series ok?
