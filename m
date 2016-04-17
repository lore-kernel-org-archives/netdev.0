From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v3 4/8] net: dsa: mv88e6xxx: add switch info
Date: Sun, 17 Apr 2016 17:35:41 +0200
Message-ID: <20160417153541.GC907@lunn.ch>
References: <1460846505-20305-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1460846505-20305-5-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1460846505-20305-5-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> @@ -3100,16 +3100,19 @@ char *mv88e6xxx_drv_probe(struct device *dsa_dev, struct device *host_dev,
>  	prod_num = (id & 0xfff0) >> 4;
>  	rev = id & 0x000f;
>  
> -	name = mv88e6xxx_lookup_name(id, table, num);
> -	if (!name)
> +	info = mv88e6xxx_lookup_info(prod_num, table, num);
> +	if (!info)
>  		return NULL;
>  
> +	name = (char *) info->name;
> +

Hi Vivien

Casting off the const is not so nice. How about adding in another
patch to change the API to return a const char *.

      Andrew
