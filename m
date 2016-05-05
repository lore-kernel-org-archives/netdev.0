From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 01/20] net: dsa: mv88e6xxx: factorize PHY
 access with PPU
Date: Fri, 6 May 2016 00:54:31 +0200
Message-ID: <20160505225431.GG7972@lunn.ch>
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
Received: from vps0.lunn.ch ([178.209.37.122]:57951 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753293AbcEEWye (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 May 2016 18:54:34 -0400
Content-Disposition: inline
In-Reply-To: <1462488064-1841-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 05, 2016 at 06:40:45PM -0400, Vivien Didelot wrote:
> Add a flags bitmap to the mv88e6xxx_info structure to help describing
> features supported or not by a switch model.
> 
> Add a MV88E6XXX_FLAG_PPU flag to describe switch models with a PHY
> Polling Unit. This allows to merge PPU specific PHY access code in the
> share code. In the meantime, use unlocked register accesses.
> 
> Since the PPU code is shared, also remove NET_DSA_MV88E6XXX_NEED_PPU.

> -#ifdef CONFIG_NET_DSA_MV88E6XXX_NEED_PPU
> -static int mv88e6xxx_ppu_disable(struct mv88e6xxx_priv_state *ps)
> +static int _mv88e6xxx_ppu_enable(struct mv88e6xxx_priv_state *ps, bool enable)
>  {
> -	int ret;

The change log does not say anything about refactoring
mv88e6xxx_ppu_disable() and mv88e6xxx_ppu_enable() into one function.
That should be in separate patch. Also, i don't see much value in this
refactoring. The names mv88e6xxx_ppu_disable() and
mv88e6xxx_ppu_enable() are much clearer than having one function which
takes a bool.

      Andrew
