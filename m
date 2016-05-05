From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 01/20] net: dsa: mv88e6xxx: factorize PHY
 access with PPU
Date: Fri, 6 May 2016 00:59:44 +0200
Message-ID: <20160505225944.GH7972@lunn.ch>
References: <1462488064-1841-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1462488064-1841-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57958 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752560AbcEEW7q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 May 2016 18:59:46 -0400
Content-Disposition: inline
In-Reply-To: <1462488064-1841-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -static int mv88e6xxx_ppu_access_get(struct mv88e6xxx_priv_state *ps)
> +static int _mv88e6xxx_ppu_access_get(struct mv88e6xxx_priv_state *ps)

Hi Vivien

We agreed to stop adding _ to functions that assume the lock has been
taken. Now that we check the lock is held in lowest level function, it
quickly becomes clear if the locks are wrong. It either deadlocks, or
it prints a warning when there is an error.

Please don't rename these functions.

       Andrew
