From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/7] net: dsa: mv88e6xxx: drop revision probing
Date: Fri, 15 Apr 2016 21:16:24 +0200
Message-ID: <20160415191624.GC18523@lunn.ch>
References: <1460744750-13896-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1460744750-13896-3-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1460744750-13896-3-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -2663,11 +2663,15 @@ int mv88e6xxx_setup_ports(struct dsa_switch *ds)
>  int mv88e6xxx_setup_common(struct dsa_switch *ds)
>  {
>  	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
> +	int id;
>  
>  	ps->ds = ds;
>  	mutex_init(&ps->smi_mutex);
>  
> -	ps->id = REG_READ(REG_PORT(0), PORT_SWITCH_ID) & 0xfff0;
> +	id = REG_READ(REG_PORT(0), PORT_SWITCH_ID);
> +
> +	ps->id = id & 0xfff0;
> +	ps->rev = id & 0xf;

ps->rev is not actually used anywhere. Drop it.

	Andrew
