From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 2/3] net: dsa: mv88e6xxx: rework EEPROM access
Date: Thu, 21 Jul 2016 02:43:07 +0200
Message-ID: <20160721004307.GD22834@lunn.ch>
References: <20160720221836.28218-1-vivien.didelot@savoirfairelinux.com>
 <20160720221836.28218-3-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160720221836.28218-3-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 20, 2016 at 06:18:35PM -0400, Vivien Didelot wrote:
> The 6352 family of switches and compatibles provide a 8-bit address and
> 16-bit data access to an optional EEPROM.
> 
> Newer chip such as the 6390 family slightly changed the access to 16-bit
> address and 8-bit data.
> 
> This commit cleans up the EEPROM access code for 16-bit access and makes
> it easy to eventually introduce future support for 8-bit access.
> 
> Here's a list of notable changes brought by this patch:
> 
>   - provide Global2 unlocked helpers for EEPROM commands
>   - remove eeprom_mutex, only reg_lock is necessary for driver functions
>   - eeprom_len is 0 for chip without EEPROM, so return it directly
>   - the Running bit must be 0 before r/w, so wait for Busy *and* Running
>   - remove now unused mv88e6xxx_wait and mv88e6xxx_reg_write
>   - other than that, the logic (in _{get,set}_eeprom16) didn't change
> 
> Chips with an 8-bit EEPROM access will require to implement the
> 8-suffixed variant of G2 helpers and the related flag:
> 
>     #define MV88E6XXX_FLAGS_EEPROM8	\
>     	(MV88E6XXX_FLAG_G2_EEPROM_CMD |	\
>     	 MV88E6XXX_FLAG_G2_EEPROM_ADDR)
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
