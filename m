From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 12/17] net: dsa: add dsa_is_normal_port helper
Date: Sat, 11 Mar 2017 18:17:58 -0800
Message-ID: <e2553201-b071-b0e5-30c2-13cf81ea6101@gmail.com>
References: <20170311211303.24560-1-vivien.didelot@savoirfairelinux.com>
 <20170311211303.24560-13-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170311211303.24560-13-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 03/11/17 à 13:12, Vivien Didelot a écrit :
> Introduce a dsa_is_normal_port helper to check if a given port is a
> normal user port as opposed to a CPU port or DSA link.

net/dsa/dsa2.c uses the "user" terminology should we use something like
that here?

> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  include/net/dsa.h | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/include/net/dsa.h b/include/net/dsa.h
> index 4e13e695f025..bf0e42c2a6f7 100644
> --- a/include/net/dsa.h
> +++ b/include/net/dsa.h
> @@ -248,6 +248,11 @@ static inline bool dsa_is_dsa_port(struct dsa_switch *ds, int p)
>  	return !!((ds->dsa_port_mask) & (1 << p));
>  }
>  
> +static inline bool dsa_is_normal_port(struct dsa_switch *ds, int p)
> +{
> +	return !dsa_is_cpu_port(ds, p) && !dsa_is_dsa_port(ds, p);
> +}
> +
>  static inline bool dsa_is_port_initialized(struct dsa_switch *ds, int p)
>  {
>  	return ds->enabled_port_mask & (1 << p) && ds->ports[p].netdev;
> 


-- 
Florian
