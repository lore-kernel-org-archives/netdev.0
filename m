From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 05/10] r6040: call napi_disable when puting down the
	interface and set lp->dev accordingly.
Date: Tue, 22 Jul 2008 23:52:18 +0200
Message-ID: <20080722215218.GB32506@electric-eye.fr.zoreil.com>
References: <200807131432.46495.florian.fainelli@telecomint.eu> <20080716210138.GB27394@electric-eye.fr.zoreil.com> <200807211232.30809.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeff@garzik.org
To: Florian Fainelli <florian.fainelli@telecomint.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:43332 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753467AbYGVVww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 17:52:52 -0400
Content-Disposition: inline
In-Reply-To: <200807211232.30809.florian.fainelli@telecomint.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <florian.fainelli@telecomint.eu> :
[...]
> Patch attached below

Thanks.

> are you okay with the other patches ?

1) The comment in "[PATCH 06/10] r6040: completely rework the RX path"
seems a it misleading to me:
! ...
! We now allocate skbs on the fly in r6040_rx, and we handle allocation
! failure instead of simply dropping the packet. Remove the
! ...

Afaiks netif_receive_skb is skipped as soon as the allocation fails.
The packet is thus still dropped, isn't it ?

2) I am a bit surprized that r6040_descriptor mixes endian tainted
fields (buf, ndesc) with untainted ones (status, len). It the latter
ought to be tainted too, it could be done in the #define lines of
"[PATCH 07/10] r6040: use definitions for magic values in descriptor status"

-- 
Ueimor
