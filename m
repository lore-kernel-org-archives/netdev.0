From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH net-next] gro: Handle inline VLAN tags
Date: Fri, 16 Nov 2012 20:17:24 -0500
Message-ID: <50A6E5A4.7060904@myri.com>
References: <1353097030.2743.28.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f46.google.com ([209.85.213.46]:65430 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753651Ab2KQBR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 20:17:27 -0500
Received: by mail-yh0-f46.google.com with SMTP id m54so614212yhm.19
        for <netdev@vger.kernel.org>; Fri, 16 Nov 2012 17:17:27 -0800 (PST)
In-Reply-To: <1353097030.2743.28.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/16/12 15:17, Ben Hutchings wrote:
> The receive paths for skbs with inline and out-of-line VLAN tags (VLAN
> RX accleration) were made largely consistent in 2.6.37, with tags
> pulled out by software as necessary.  However GRO doesn't do this, so
> it is not effective for VLAN-tagged packets received on devices
> without VLAN RX acceleration.
>
> napi_gro_frags() must not free the skb and does not advance the
> skb->data pointer, so cannot use vlan_untag().  Extract the core of
> vlan_untag() into a new function __vlan_untag() that allows the offset
> to the VLAN tag to be specified and returns an error code.  Add
> kernel-doc comments for both those functions.
>
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> Tested with sfc using both napi_gro_receive() and napi_gro_frags().  On
> a Core i7 920 (Nehalem) system it increased TCP/IPv4 receive throughput
> over a VLAN from ~8.0 to ~9.3 Gbit/s.


I verified similar results on myri10ge, using my recent GRO
patchset (minus the in-driver vtag removal) with just
napi_gro_frags().

I've no strong feeling as to whether or not this belongs in GRO or the
driver.  I'm just glad that it is being discussed.

Thank you,

Drew
