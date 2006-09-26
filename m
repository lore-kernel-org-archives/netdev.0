From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 02/11] 3x59x: fix PCI resource management
Date: Mon, 25 Sep 2006 20:02:41 -0400
Message-ID: <45186E21.7000202@garzik.org>
References: <200609252339.k8PNdGBp002625@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, sshtylyov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:29912 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751810AbWIZACo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 20:02:44 -0400
To: akpm@osdl.org
In-Reply-To: <200609252339.k8PNdGBp002625@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> From: Jeff Garzik <jgarzik@pobox.com>
> 
> The driver wrongly claimed I/O ports at an address returned by pci_iomap()
> -- even if it was passed an MMIO address.  Fix this by claiming/releasing
> all PCI resources in the PCI driver probe/remove handlers instead and get
> rid of the must_free_region flag weirdness (why would Cardbus claim
> anything for us?).
> 
> Also, the remove handler was trying to talk to the chip after having
> disabled its address decoders (at least on x86) -- fix this and get rid of
> useless VORTEX_PCI() calls.
> 
> While at it, fix some cases of the overly indented code...
> 
> Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>
> Cc: Jeff Garzik <jgarzik@pobox.com>
> 
> - Would prefer that vortex_init_one() do the `goto out_release;' thing
>   rather than having multiple cleanup-then-return points.
> 
> - I don't remember the story with cardbus either.  Presumably once upon a
>   time the cardbus layer was claiming IO regions on behalf of cardbus
>   devices (?)
> 
> Signed-off-by: Andrew Morton <akpm@osdl.org>

ACK + HOLD, waiting to see if someone actually tested it

