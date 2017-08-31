From: Mason <slash.tmp@free.fr>
Subject: Re: [PATCH net] Revert "net: phy: Correctly process PHY_HALTED in
 phy_stop_machine()"
Date: Thu, 31 Aug 2017 19:49:47 +0200
Message-ID: <d6a6b552-95a7-8353-54c8-fa804f9366a1@free.fr>
References: <1504140569-2063-1-git-send-email-f.fainelli@gmail.com>
 <f4bb5ac8-dae8-c0af-7aa6-e546fc0783fa@sigmadesigns.com>
 <e24693e8-d8ae-188a-2a38-c9a83fdc94e3@gmail.com>
 <931bf454-81ff-94dc-82e6-bc2b889bd43a@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        netdev <netdev@vger.kernel.org>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        David Miller <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
        David Daney <ddaney.cavm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:62201 "EHLO smtp2-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751811AbdHaRty (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 31 Aug 2017 13:49:54 -0400
In-Reply-To: <931bf454-81ff-94dc-82e6-bc2b889bd43a@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31/08/2017 18:57, Florian Fainelli wrote:
> And the race is between phy_detach() setting phydev->attached_dev = NULL
> and phy_state_machine() running in PHY_HALTED state and calling
> netif_carrier_off().

I must be missing something.
(Since a thread cannot race against itself.)

phy_disconnect calls phy_stop_machine which
1) stops the work queue from running in a separate thread
2) calls phy_state_machine *synchronously*
     which runs the PHY_HALTED case with everything well-defined
end of phy_stop_machine

phy_disconnect only then calls phy_detach()
which makes future calls of phy_state_machine perilous.

This all happens in the same thread, so I'm not yet
seeing where the race happens?

Regards.
