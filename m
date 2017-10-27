From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC net-next 0/4] net: phy: PHY_HALTED, the return of the state
Date: Fri, 27 Oct 2017 13:35:18 +0200
Message-ID: <20171027113518.GD17415@lunn.ch>
References: <20171025232124.14120-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, opendmb@gmail.com,
        Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        slash.tmp@free.fr, david.daney@cavium.com, geert+renesas@glider.be
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:59755 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752411AbdJ0Lfd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 27 Oct 2017 07:35:33 -0400
Content-Disposition: inline
In-Reply-To: <20171025232124.14120-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 25, 2017 at 04:21:20PM -0700, Florian Fainelli wrote:
> Hi all,
> 
> This patch series tries to address the shortcomings of the previously and then
> quickly reverted commit 7ad813f208533cebfcc32d3d7474dc1677d1b09a ("net: phy:
> Correctly process PHY_HALTED in phy_stop_machine()")
> 
> This time, the empire returns and strikes back with a few additional changes:
> 
> - catch phy_disconnect() calls without prior phy_stop() and warn when that
>   happens since that means a driver is not behaving properly. This is AFAIR
>   the case in which David Daney ran into
> 
> - what David also was running into is that when the PHY state machine was
>   already in PHY_HALTED, its synchronous call in phy_disconnect() would make
>   us re-schedule ourselves at the end. This is unnecessary, and we now take
>   care of that
> 
> - finally, Geert experienced bus errors on smsc911x for a number of reasons,
>   but the primary one is that the driver does not do any management of the
>   PHY state machine during suspend/resume. The last patch corrects that, and
>   also suggests that the driver should be fixed to properly support Wake-on-LAN
>   configuration to possibly suspend the PHY.
> 
> David, Marc and Geert, I would appreciate if you could give this patch series
> a spin on your respective HW and confirm that the desired functionality is
> achieved.

Hi Florian

I quickly look through these patches and they all seem
sensible. Feedback from the listed people would however be good.

	  Andrew
