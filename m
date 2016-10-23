From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH] batman-adv: Revert "use core MTU range checking in misc
 drivers"
Date: Sat, 22 Oct 2016 21:08:26 -0400
Message-ID: <20161023010826.GD32569@redhat.com>
References: <20161022074624.30033-1-sven@narfation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        b.a.t.m.a.n@lists.open-mesh.org, linux-kernel@vger.kernel.org
To: Sven Eckelmann <sven@narfation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f176.google.com ([209.85.216.176]:35557 "EHLO
        mail-qt0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756164AbcJWBIb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Oct 2016 21:08:31 -0400
Received: by mail-qt0-f176.google.com with SMTP id f6so112060402qtd.2
        for <netdev@vger.kernel.org>; Sat, 22 Oct 2016 18:08:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20161022074624.30033-1-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 22, 2016 at 09:46:24AM +0200, Sven Eckelmann wrote:
> The maximum MTU is defined via the slave devices of an batman-adv
> interface. Thus it is not possible to calculate the max_mtu during the
> creation of the batman-adv device when no slave devices are attached. Doing
> so would for example break non-fragmentation setups which then
> (incorrectly) allow an MTU of 1500 even when underlying device cannot
> transport 1500 bytes + batman-adv headers.
> 
> Checking the dynamically calculated max_mtu via the minimum of the slave
> devices MTU during .ndo_change_mtu is also used by the bridge interface.
> 
> Cc: Jarod Wilson <jarod@redhat.com>
> Fixes: b3e3893e1253 ("net: use core MTU range checking in misc drivers")
> Signed-off-by: Sven Eckelmann <sven@narfation.org>
> ---
> Original patch + my comment: https://patchwork.ozlabs.org/patch/684722/
> 
> I just got informed about this patch when it was already applied in net-next.
> So I can only ask for an revet of the batman-adv parts

Apologies, I tried to cc everyone I could find in MAINTAINERS, but your
name wasn't one of the three listed for batman devices. You're going to
need more than just this revert though, since batman-adv calls
ether_setup, which will set min_mtu = 68, max_mtu = 1500, unless
batadv_hardif_min_mtu() always returns something 1500 or less. Actually,
looking at that, you could omit the mtu < 68 bit from
batadv_interface_change_mtu() too, since that'll already get done in the
core, but I have no clue what you need for max_mtu.

-- 
Jarod Wilson
jarod@redhat.com
