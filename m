From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 04/21] net: dsa: mv88e6xxx: factorize EEPROM
 access
Date: Sat, 7 May 2016 00:20:08 +0200
Message-ID: <20160506222008.GA2073@lunn.ch>
References: <1462571843-14397-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1462571843-14397-5-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1462571843-14397-5-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> @@ -2596,6 +2797,9 @@ int mv88e6xxx_setup_common(struct mv88e6xxx_priv_state *ps)
>  
>  	INIT_WORK(&ps->bridge_work, mv88e6xxx_bridge_work);
>  
> +	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_EEPROM))
> +		mutex_init(&ps->eeprom_mutex);
> +

This seems to be the only place MV88E6XXX_FLAG_EEPROM is checked.  It
seems like mv88e6xxx_get_eeprom() and and mv88e6xxx_set_eeprom()
should also check this.

       Andrew
