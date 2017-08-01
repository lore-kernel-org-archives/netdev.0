From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] net: phy: Correctly process PHY_HALTED in
 phy_stop_machine()
Date: Mon, 31 Jul 2017 17:28:18 -0700 (PDT)
Message-ID: <20170731.172818.1505741655348122155.davem@davemloft.net>
References: <20170728185836.28759-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, slash.tmp@free.fr,
        marc_gonzalez@sigmadesigns.com, rmk+kernel@armlinux.org.uk
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48346 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751106AbdHAA2T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 20:28:19 -0400
In-Reply-To: <20170728185836.28759-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 28 Jul 2017 11:58:36 -0700

> Marc reported that he was not getting the PHY library adjust_link()
> callback function to run when calling phy_stop() + phy_disconnect()
> which does not indeed happen because we set the state machine to
> PHY_HALTED but we don't get to run it to process this state past that
> point.
> 
> Fix this with a synchronous call to phy_state_machine() in order to have
> the state machine actually act on PHY_HALTED, set the PHY device's link
> down, turn the network device's carrier off and finally call the
> adjust_link() function.
> 
> Reported-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
> Fixes: a390d1f379cf ("phylib: convert state_queue work to delayed_work")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> Changes in v2:
> 
> - reword subject and commit message based on changes
> - dropped flush_scheduled_work() since it is redundant

Applied and queued up for -stable, thanks.
