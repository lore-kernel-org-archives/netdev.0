From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 net-next v3 13/14] net: dsa: mv88e6xxx: add addressing
 mode to info
Date: Sat, 18 Jun 2016 22:36:39 +0200
Message-ID: <20160618203639.GH7172@lunn.ch>
References: <20160618000736.5598-1-vivien.didelot@savoirfairelinux.com>
 <20160618000736.5598-14-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Ben Dooks <ben.dooks@codethink.co.uk>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160618000736.5598-14-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +struct mv88e6xxx_smi_ops {
> +	int (*read)(struct mii_bus *bus, int sw_addr,
> +		    int addr, int reg, u16 *val);
> +	int (*write)(struct mii_bus *bus, int sw_addr,
> +		     int addr, int reg, u16 val);
> +};

Hi Vivien

I still think this API should be based on ps.

With the way you have restructured probe, this now also works, there
is no longer a read without PS in order to get the device ID.

Also, think about the case of reading/writing registers via Ethernet
frames. Such functions would need ps, bus and sw_addr is not useful.

	Andrew
