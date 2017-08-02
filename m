From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [for 4.13] net: qcom/emac: disable flow control
 autonegotiation by default
Date: Wed, 02 Aug 2017 10:54:53 -0700 (PDT)
Message-ID: <20170802.105453.1408822174555343968.davem@davemloft.net>
References: <1501623460-3575-1-git-send-email-timur@codeaurora.org>
        <1501623460-3575-2-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55138 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751923AbdHBRyy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 13:54:54 -0400
In-Reply-To: <1501623460-3575-2-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@codeaurora.org>
Date: Tue,  1 Aug 2017 16:37:39 -0500

> The EMAC has a curious qwirk when RX flow control is enabled and the
> kernel hangs.  With the kernel hung, the EMAC's RX queue soon fills.
> If RX flow control is enabled, the EMAC will then send a non-stop
> stream of pause frames until the system is reset.  The EMAC does not
> have a built-in watchdog.
> 
> In various tests, the pause frame stream sometimes overloads nearby
> switches, effectively disabling the network.  Since the RX queue is
> large and the host processor is more than capable of handling incoming
> packets quickly, the only time the EMAC will send any pause frames is
> when the kernel is hung and unrecoverable.
> 
> To avoid all these problems, we disable flow control autonegotiation
> by default, and only enable receiving pause frames.
> 
> Cc: stable@vger.kernel.org # 4.11.x
> Signed-off-by: Timur Tabi <timur@codeaurora.org>

I've thought about this a lot and I don't like it for many reasons.

First of all, this hung kernel scenerio is completely bogus.

The ethernet chip may not have a proper watchdog for the pause frame
generation logic, but the whole kernel sure as hell does.

And if this kind of thing matters to the user, they will have a
software or hardware watchdog driver enabled to break out of this
situation.

Turning off flow control by default has so many negative ramifications
and don't try to convince me that users will be "aware" of this and
turn it back on.

They largely won't.
