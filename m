From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] e1000e: Fix usage under kexec
Date: Tue, 10 Nov 2009 10:35:37 +0100
Message-ID: <87tyx2k9hy.fsf@basil.nowhere.org>
References: <4AF87AB1.1070603@anduras.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Sven Anders <sven@anduras.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:36385 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753441AbZKJJfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 04:35:33 -0500
In-Reply-To: <4AF87AB1.1070603@anduras.de> (Sven Anders's message of "Mon, 09 Nov 2009 21:25:21 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sven Anders <sven@anduras.de> writes:
>
> We get the following error:
>   e1000e: probe of 0000:02:00.0 failed with error -2
>
> We cannot unload the driver of the first kernel, because it's
> compiled in statically.
>
> It's caused by the PHY, because it's already initialized by the
> first driver and therefore does not respond correctly. The driver
> assumes the PHY to be in 'reset' state, which is done by the BIOS.
>
> We fixed it by adding a
>
> +       /* Reset PHY before initializing it. Allows re-init after kexec. */
> +       if (!e1000_check_reset_block(hw))
> +         e1000_phy_hw_reset(hw);

The problem of resetting PHYs in the driver init path is that it tends
to lose link-state, and if the link takes some time to re-negotiate
you can significantly slow down the "total time to network access"
at boot.

Perhaps you could only reset when the message above would trigger
and try again?

-Andi
