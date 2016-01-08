From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH v2 net-next 3/5] net: vxlan: enable local checksum offload
Date: Fri, 8 Jan 2016 15:39:48 +0000
Message-ID: <568FD844.3020101@solarflare.com>
References: <568E9BF9.2050001@solarflare.com>
 <568E9C9B.3090408@solarflare.com>
 <CAKgT0UfqNgdRYhVRJtT24oBKK4SBqy+QOtWQdD4H09zo2sj32A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>,
	Tom Herbert <tom@herbertland.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:27768 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755324AbcAHPj7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 10:39:59 -0500
In-Reply-To: <CAKgT0UfqNgdRYhVRJtT24oBKK4SBqy+QOtWQdD4H09zo2sj32A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/01/16 03:46, Alexander Duyck wrote:
> So I just tried testing your patches and as it turns out you are still
> missing some bits.  In this patch for instance the calls to
> udp_tunnel_xmit_skb and udp_tunnel6_xmit skb need to be updated so
> that you pass false for the last parameter and allow the use of your
> udp_set_csum modifications.
>
> - Alex
Are you remembering to enable outer checksums on your vxlan tunnel?  It's
 the vxflags & VXLAN_F_UDP_CSUM check, and to enable it you need a recent
 iproute2 so you can use the 'udpcsum' option when creating the vxlan device.
It would be nice if that could just default to enabled now that we have LCO,
 but I don't think we can change that now (ABIs set in stone and all that),
 so I think it would have to be iproute2 that turned it on by default.

-ed
