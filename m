From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: fec: Allow reception of frames bigger
 than 1522 bytes
Date: Sun, 30 Jul 2017 19:26:29 -0700 (PDT)
Message-ID: <20170730.192629.124814765201077334.davem@davemloft.net>
References: <1501436165-20259-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fugang.duan@nxp.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59262 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751789AbdGaC0a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2017 22:26:30 -0400
In-Reply-To: <1501436165-20259-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Sun, 30 Jul 2017 19:36:05 +0200

> The FEC Receive Control Register has a 14 bit field indicating the
> longest frame that my be received. It is being set to 1522. Frames
> longer than this are discarded, but counted as being in error.
> 
> When using DSA, frames from the switch has an additional header,
> either 4 or 8 bytes if a Marvell switch is used. Thus a full MTU frame
> of 1522 bytes received by the switch on a port becomes 1530 bytes when
> passed to the host via the FEC interface.
> 
> Change the maximum receive size to 2048 - 64, where 64 is the maximum
> rx_alignment applied on the receive buffer for AVB capable FEC
> cores. Use this value also for the maximum receive buffer size. The
> driver is already allocating a receive SKB of 2048 bytes, so this
> change should not have any significant effects.
> 
> Tested on imx51, imx6, vf610.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Applied with commit log message typo fixed.
