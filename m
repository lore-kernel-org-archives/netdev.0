From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: [PATCH v1 2/2] net: emac: fix and unify emac_mdio functions
Date: Tue, 06 Jun 2017 00:22:47 +0200
Message-ID: <2091321.vBEAWt7qWg@debian64>
References: <635dd014238af6f48c4169439b7ac161e80de1b7.1496695540.git.chunkeey@googlemail.com> <18472d9a6bde3edaab7dcda301ccaebd437ea0dc.1496695540.git.chunkeey@googlemail.com> <20170605214333.GA12386@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        Ivan Mikhaylov <ivan@de.ibm.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:33685 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751243AbdFEWWz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 18:22:55 -0400
Received: by mail-wr0-f194.google.com with SMTP id v104so8721663wrb.0
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 15:22:54 -0700 (PDT)
In-Reply-To: <20170605214333.GA12386@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, June 5, 2017 11:43:33 PM CEST Andrew Lunn wrote:
> On Mon, Jun 05, 2017 at 10:49:40PM +0200, Christian Lamparter wrote:
> > emac_mdio_read_link() was not copying the requested phy settings
> > back into the emac driver's own phy api. This has caused a link
> > speed mismatch issue for the AR8035 as the emac driver kept
> > trying to connect with 10/100MBps on a 1GBit/s link.

> In the long run, you might want to remove the emac phy drivers. 
> Linux has PHYLIB drivers for all but the bcm5248.

Hello Andrew

Back in February I added PHYLIB support to emac.
<https://www.spinics.net/lists/netdev/msg421734.html> ;)

I could add a separate patch that adds a oneliner message like:
    pr_info("EMAC supports PHYLIB. Please convert your device to it.\n");
at the right place (emac_mii_phy_probe) to let people know about it.

Is that Ok? If not, please tell me what the appropriate deprecation 
notice should look like.

About the MR24:
I do have a patchset to convert the MR24 to use PHYLIB's at803x as well.
<https://github.com/chunkeey/apm82181-lede/commit/82c50b7f4fca68ce905d4a7a3559700635bf227f>
But because of AT8035 "special tx/rx delay" requirements, this
will need a patched at803x.c driver as well.

Regards,
Christian
