From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] pcnet32: fix BNC/AUI port on AM79C970A
Date: Tue, 14 Feb 2017 14:28:56 -0500 (EST)
Message-ID: <20170214.142856.670670406050328036.davem@davemloft.net>
References: <1487025947-28867-1-git-send-email-linux@rainbow-software.org>
        <1487025947-28867-2-git-send-email-linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pcnet32@frontier.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: linux@rainbow-software.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1487025947-28867-2-git-send-email-linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ondrej Zary <linux@rainbow-software.org>
Date: Mon, 13 Feb 2017 23:45:47 +0100

> Even though the port autoselection is enabled by default on AM79C970A,
> BNC/AUI port does not work because the link is always reported to be
> down. The link state reported by the chip belongs only to the TP port
> but the driver uses it regardless of the port used. The chip can't
> detect BNC/AUI link state.
> 
> Disable port autoselection and use TP port by default to keep current
> behavior (link detection works on TP port, BNC/AUI port does not work).
> 
> Implement ethtool autoneg, port and duplex configuration to allow
> using the BNC/AUI port.
> 
> Report the TP link state only if the TP port is selected. When the
> port autoselection is enabled or AUI port is selected, report the link
> as always up.
> 
> Move pcnet32_suspend() and pcnet32_clr_suspend() functions to avoid
> forward declarations.
> 
> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>

Also applied to net-next, thanks.

Are you really sure the is no way to discover the BNC/AUI link state
from the hardware?
