From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 11/13] net: ethernet: aquantia: Refactoring
 buffers copying.
Date: Thu, 16 Feb 2017 13:10:06 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFE68133@AcuExch.aculab.com>
References: <cover.1487187192.git.pavel.belous@aquantia.com>
 <de4d3c34fac8c7bbbb614f776ca1255fd6aa03a6.1487187192.git.pavel.belous@aquantia.com>
 <4262ef98-4ba5-3f1a-5b72-208be51bdd6f@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>
To: 'Lino Sanfilippo' <LinoSanfilippo@gmx.de>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.186]:55278 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754065AbdBPNKR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 08:10:17 -0500
In-Reply-To: <4262ef98-4ba5-3f1a-5b72-208be51bdd6f@gmx.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lino Sanfilippo
> Sent: 15 February 2017 21:31
...
> Well, you should really try to avoid copying the tx buffers _at all_.
> E.g. by passing self->buff_ring to aq_ring_tx_append_buffs() instead of
> the temporary array.

Copying can help for horridly fragmented frames or when iommu (etc)
setup is expensive.
At least some ethernet hardware has minimum fragment lengths.

However, if the frame doesn't fit at the end - just copy to the front.

Something should ensure the copies are aligned (you may want gaps
between frames.)

I presume there is a 'space in buffer' check elsewhere.

	David
