From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: [PATCH v1 1/2] net: emac: fix reset timeout with AR8035 phy
Date: Mon, 05 Jun 2017 23:44:46 +0200
Message-ID: <21110017.iteKCRmsvN@debian64>
References: <635dd014238af6f48c4169439b7ac161e80de1b7.1496695540.git.chunkeey@googlemail.com> <20170605212617.GC9339@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        Ivan Mikhaylov <ivan@de.ibm.com>,
        Chris Blake <chrisrblake93@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f169.google.com ([209.85.128.169]:34589 "EHLO
        mail-wr0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751189AbdFEVot (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 17:44:49 -0400
Received: by mail-wr0-f169.google.com with SMTP id g76so45045596wrd.1
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 14:44:48 -0700 (PDT)
In-Reply-To: <20170605212617.GC9339@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, June 5, 2017 11:26:17 PM CEST Andrew Lunn wrote:
> > In order to stay compatible with existing configurations, the
> > driver will try the normal reset first and only falls back to
> > to the internal clock, after the first reset fails. If the
> > second reset fails as well, it will give up as before.
> 
> Hi Christian
> 
> This gets things probed correctly. But should you swap back to the PHY
> clock when the PHY declares the link up? Is there code already to do
> this?
> 
> 	Andrew
> 
Oh, sorry. I omitted this from the commit message. But the proposed 
emac_reset() code  switched to the internal clock only after the first attempt
has failed AND only for the duration of the reset.

If the reset succeeds or the reset times out, the clock is always switched 
back to the external clock.

Thanks,
Christian
