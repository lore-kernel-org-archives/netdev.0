From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH v2 net-next 1/2] net: dsa: lan9303: Move tag setup to
 new lan9303_setup_tagging
Date: Tue, 10 Oct 2017 15:14:30 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40B48C3D@CHN-SV-EXMX02.mchp-main.com>
References: <20171010124953.386-1-privat@egil-hjelmeland.no>
 <20171010124953.386-2-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <privat@egil-hjelmeland.no>, <andrew@lunn.ch>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171010124953.386-2-privat@egil-hjelmeland.no>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +/* forward special tagged packets from port 0 to port 1 *or* port 2 */
> +static int lan9303_setup_tagging(struct lan9303 *chip)
> +{
> +	int ret;
> +	u32 val;
> +	/* enable defining the destination port via special VLAN tagging
> +	 * for port 0
> +	 */
> +	ret = lan9303_write_switch_reg(chip,
> LAN9303_SWE_INGRESS_PORT_TYPE,
> +
> LAN9303_SWE_INGRESS_PORT_TYPE_VLAN);
> +	if (ret)
> +		return ret;
> +
> +	/* tag incoming packets at port 1 and 2 on their way to port 0 to be
> +	 * able to discover their source port
> +	 */
> +	val = LAN9303_BM_EGRSS_PORT_TYPE_SPECIAL_TAG_PORT0;
> +	return lan9303_write_switch_reg(chip,
> LAN9303_BM_EGRSS_PORT_TYPE, val);
Specific reason to use val then using LAN9303_BM_EGRSS_PORT_TYPE_SPECIAL_TAG_PORT0
like previous line?

> @@ -644,6 +648,10 @@ static int lan9303_setup(struct dsa_switch *ds)
>  		return -EINVAL;
>  	}
> 
> +	ret = lan9303_setup_tagging(chip);
> +	if (ret)
> +		dev_err(chip->dev, "failed to setup port tagging %d\n", ret);
> +
Still move on when error happens?

>  	ret = lan9303_separate_ports(chip);
>  	if (ret)
>  		dev_err(chip->dev, "failed to separate ports %d\n", ret);
> --
> 2.11.0

- Woojung
