From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] benet: stricter vxlan offloading check in
 be_features_check
Date: Tue, 03 Jan 2017 10:59:08 -0500 (EST)
Message-ID: <20170103.105908.383460652152996780.davem@davemloft.net>
References: <59e720bde70fb5226313c62d89b62cbbef25b3e2.1483455910.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sathya.perla@broadcom.com,
        ajit.khaparde@broadcom.com, sriharsha.basavapatna@broadcom.com,
        somnath.kotur@broadcom.com
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39040 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935293AbdACP7K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 10:59:10 -0500
In-Reply-To: <59e720bde70fb5226313c62d89b62cbbef25b3e2.1483455910.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Tue,  3 Jan 2017 16:26:04 +0100

> When VXLAN offloading is enabled, be_features_check() tries to check if
> an encapsulated packet is indeed a VXLAN packet. The check is not strict
> enough, and considers any UDP-encapsulated ethernet frame with a 8-byte
> tunnel header as being VXLAN. Unfortunately, both GENEVE and VXLAN-GPE
> have a 8-byte header, so they get through this check.
> 
> Force the UDP destination port to be the one that has been offloaded to
> hardware.
> 
> Without this, GENEVE-encapsulated packets can end up having an incorrect
> checksum when both a GENEVE and a VXLAN (offloaded) tunnel are
> configured.
> 
> This is similar to commit a547224dceed ("mlx4e: Do not attempt to
> offload VXLAN ports that are unrecognized").
> 
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Applied, thanks.
