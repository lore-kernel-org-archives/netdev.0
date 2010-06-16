From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] vlan_dev: VLAN 0 should be treated as "no vlan tag" (802.1p packet)
Date: Wed, 16 Jun 2010 20:26:28 +0200
Message-ID: <201006162026.28900.arnd@arndb.de>
References: <c25bca517739ada31d698235c3a4d045@dondevamos.com> <201006161624.12101.arnd@arndb.de> <4C18ED97.3060702@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Pedro Garcia <pedro.netdev@dondevamos.com>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:57202 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752409Ab0FPS0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 14:26:43 -0400
In-Reply-To: <4C18ED97.3060702@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 16 June 2010 17:28:23 Patrick McHardy wrote:

> Since we don't have any special VLAN handling in the bridging code, I
> guess it comes down to optionally using a different ethertype value
> (0x88a8) in the VLAN code. We probably also need some indication from
> device drivers whether they are able to add these headers to avoid
> trying to offload tagging in case they're not.

It's probably a little more than just supporting the new ethertype, but not
much. The outer tag can be handled like our current VLAN module does,
but the standard does not allow a regular frame to be encapsulated directly,
but rather requires one of 

1. In 802.1ad: an 802.1Q VLAN tag (ethertype 0x8100) followed by the frame
2. In 802.1ah: A service tag (ethertype 0x88e7) followed by the 802.1Q VLAN tag
   and then the frame.

Maybe what we can do is extend the vlan code to understand all three frame
formats (q, ad and ah) or at least the first two so we configure both the
provider VID and the Customer VID for the interface in case of 802.1ad but
only the regular VID in 802.1Q.

Device drivers can then flag whether they support both formats or just
the regular Q tag.

	Arnd
