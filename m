From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH 3/3] net: fec: align IP header in hardware
Date: Wed, 28 Sep 2016 18:25:30 +0100
Message-ID: <20160928172530.GM1041@n2100.armlinux.org.uk>
References: <AM4PR0401MB22609D8151C2B63CA7768A1AFFCB0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <1474728139-9335-1-git-send-email-eric@nelint.com>
 <1474728139-9335-4-git-send-email-eric@nelint.com>
 <063D6719AE5E284EB5DD2968C1650D6DB0109865@AcuExch.aculab.com>
 <4d199f32-092c-1c0a-7a01-6d0d317ef676@nelint.com>
 <063D6719AE5E284EB5DD2968C1650D6DB010A73F@AcuExch.aculab.com>
 <5cf173c4-84e0-f309-f356-35b114cc166e@nelint.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "andrew@lunn.ch" <andrew@lunn.ch>,
        "fugang.duan@nxp.com" <fugang.duan@nxp.com>,
        "otavio@ossystems.com.br" <otavio@ossystems.com.br>,
        "edumazet@google.com" <edumazet@google.com>,
        "troy.kisky@boundarydevices.com" <troy.kisky@boundarydevices.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "u.kleine-koenig@pengutronix.de" <u.kleine-koenig@pengutronix.de>
To: Eric Nelson <eric@nelint.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:46294 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932977AbcI1RZo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 13:25:44 -0400
Content-Disposition: inline
In-Reply-To: <5cf173c4-84e0-f309-f356-35b114cc166e@nelint.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 28, 2016 at 10:14:52AM -0700, Eric Nelson wrote:
> Thanks David,
> 
> On 09/28/2016 09:42 AM, David Laight wrote:
> > From reading this it seems that the effect of FEC_RACC_SHIFT16 is to
> > add two bytes of 'junk' to the start of every receive frame.
> 
> That's right. Two bytes of junk between the MAC header and the
> IP header.

That's wrong.  FEC_RACC_SHIFT16 adds two bytes to the _beginning_ of
the packet, not in the middle of the packet:

   7      RX FIFO Shift-16
 SHIFT16
          When this field is set, the actual frame data starts at bit 16
          of the first word read from the RX FIFO aligning the Ethernet
          payload on a 32-bit boundary.

          NOTE: This function only affects the FIFO storage and has no
                influence on the statistics, which use the actual length
                of the frame received.

          0    Disabled.
          1    Instructs the MAC to write two additional bytes in front
               of each frame received into the RX FIFO.

*in front* of the frame - that's before the Ethernet header.  Not between
the ethernet and IP headers.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
