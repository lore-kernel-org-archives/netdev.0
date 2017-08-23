From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH net v2 2/2] net: dsa: skb_put_padto() already frees nskb
Date: Wed, 23 Aug 2017 21:42:47 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40B05FE2@CHN-SV-EXMX02.mchp-main.com>
References: <20170822221215.16305-1-f.fainelli@gmail.com>
 <20170822221215.16305-3-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <vivien.didelot@savoirfairelinux.com>,
        <UNGLinuxDriver@microchip.com>
To: <f.fainelli@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa3.microchip.iphmx.com ([68.232.153.233]:13307 "EHLO
        esa3.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751026AbdHWVnC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 17:43:02 -0400
In-Reply-To: <20170822221215.16305-3-f.fainelli@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The first call of skb_put_padto() will free up the SKB on error, but we
> return NULL which tells dsa_slave_xmit() that the original SKB should be
> freed so this would lead to a double free here.
> 
> The second skb_put_padto() already frees the passed sk_buff reference
> upon error, so calling kfree_skb() on it again is not necessary.
> 
> Detected by CoverityScan, CID#1416687 ("USE_AFTER_FREE")
> 
> Fixes: e71cb9e00922 ("net: dsa: ksz: fix skb freeing")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Woojung Huh <Woojung.Huh@microchip.com>

- Woojung
