From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next v3 0/4] net: dsa: mv88e6xxx: rework reset
 and PPU code
Date: Tue, 06 Dec 2016 11:33:44 -0500 (EST)
Message-ID: <20161206.113344.184595713713966514.davem@davemloft.net>
References: <20161205223028.20308-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch,
        eichest@gmail.com, richardcochran@gmail.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43242 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752646AbcLFQoj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 11:44:39 -0500
In-Reply-To: <20161205223028.20308-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Mon,  5 Dec 2016 17:30:24 -0500

> Old Marvell chips (like 88E6060) don't have a PHY Polling Unit (PPU).
> 
> Next chips (like 88E6185) have a PPU, which has exclusive access to the
> PHY registers, thus must be disabled before access.
> 
> Newer chips (like 88E6352) have an indirect mechanism to access the PHY
> registers whenever, thus loose control over the PPU (always enabled).
> 
> Here's a summary:
> 
> Model | PPU? | Has PPU ctrl?  | PPU state readable? | PHY access
> ----- | ---- | -------------- | ------------------- | ----------
>  6060 | no   | no             | no                  | direct
>  6185 | yes  | yes, PPUEn bit | yes, PPUState 2-bit | direct w/ PPU dis.
>  6352 | yes  | no             | yes, PPUState 1-bit | indirect
>  6390 | yes  | no             | yes, InitState bit  | indirect
> 
> Depending on the PPU control, a switch may have to restart the PPU when
> resetting the switch. Once the switch is reset, we must wait for the PPU
> state to be active polling again before accessing the registers.
> 
> For that purpose, add new operations to the chips to enable/disable the
> PPU, and execute software reset. With these new ops in place, rework the
> switch reset code and finally get rid of the MV88E6XXX_FLAG_PPU* flags.

Series applied, thanks Vivien.

And thanks for the detailed, informative, header postings like this one.
