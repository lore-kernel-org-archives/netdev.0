From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] ipv4: fix tunneled VM traffic over hw
 VXLAN/GRE GSO NIC
Date: Wed, 18 Dec 2013 16:35:33 -0800
Message-ID: <20131218163533.21a16709@nehalam.linuxnetplumber.net>
References: <1387393368-1028-1-git-send-email-weichunc@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eric.dumazet@gmail.com, ast@plumgrid.com,
	netdev@vger.kernel.org, joseph.gasparakis@intel.com,
	or.gerlitz@gmail.com
To: Wei-Chun Chao <weichunc@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:53168 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751204Ab3LSAfh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 19:35:37 -0500
Received: by mail-pb0-f46.google.com with SMTP id md12so388890pbc.5
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 16:35:36 -0800 (PST)
In-Reply-To: <1387393368-1028-1-git-send-email-weichunc@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Dec 2013 11:02:48 -0800
Wei-Chun Chao <weichunc@plumgrid.com> wrote:

> This is also seen on 'net'.
> 
> VM to VM GSO traffic is broken if it goes through VXLAN or GRE
> tunnel and the physical NIC on the host supports hardware VXLAN/GRE
> GSO offload (e.g. bnx2x and next-gen mlx4).
> 
> Two issues -
> (VXLAN) VM traffic has SKB_GSO_DODGY and SKB_GSO_UDP_TUNNEL with
> SKB_GSO_TCP/UDP set depending on the inner protocol. GSO header
> integrity check fails in udp4_ufo_fragment if inner protocol is
> TCP. Also gso_segs is calculated incorrectly using skb->len that
> includes tunnel header. Fix: robust check should only be applied
> to the inner packet.
> 
> (VXLAN & GRE) Once GSO header integrity check passes, NULL segs
> is returned and the original skb is sent to hardware. However the
> tunnel header is already pulled. Fix: tunnel header needs to be
> restored so that hardware can perform GSO properly on the original
> packet.
> 
> Signed-off-by: Wei-Chun Chao <weichunc@plumgrid.com>
> ---

Is there someway the tunnel could fixup the GSO bits?
