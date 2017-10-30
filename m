From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 3/7] net: dsa: get port type at parse time
Date: Mon, 30 Oct 2017 11:39:01 -0700
Message-ID: <d45c07a3-940b-e2f3-8011-e44ca074a502@gmail.com>
References: <20171027195519.5931-1-vivien.didelot@savoirfairelinux.com>
 <20171027195519.5931-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171027195519.5931-4-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/27/2017 12:55 PM, Vivien Didelot wrote:
> Assign a port's type at parsed time instead of waiting for the tree to
> be completed.
> 
> Because this is now done earlier, we can use the port's type in
> dsa_port_is_* helpers instead of digging again in topology description.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

One nit below:


>  static int dsa_port_parse_of(struct dsa_port *dp, struct device_node *dn)
>  {
> +	struct device_node *ethernet = of_parse_phandle(dn, "ethernet", 0);
> +	struct device_node *link = of_parse_phandle(dn, "link", 0);
> +
> +	if (ethernet) {
> +		dp->type = DSA_PORT_TYPE_CPU;
> +	} else if (link) {
> +		dp->type = DSA_PORT_TYPE_DSA;
> +	} else {
> +		dp->type = DSA_PORT_TYPE_USER;
> +	}
> +

The curly braces are probably not necessary since all of these are
single line statements.

>  	dp->dn = dn;
>  
>  	return 0;
> @@ -630,6 +629,14 @@ static int dsa_parse_ports_of(struct device_node *dn, struct dsa_switch *ds)
>  static int dsa_port_parse(struct dsa_port *dp, const char *name,
>  			  struct device *dev)
>  {
> +	if (!strcmp(name, "cpu")) {
> +		dp->type = DSA_PORT_TYPE_CPU;
> +	} else if (!strcmp(name, "dsa")) {
> +		dp->type = DSA_PORT_TYPE_DSA;
> +	} else {
> +		dp->type = DSA_PORT_TYPE_USER;
> +	}

Likewise.
-- 
Florian
