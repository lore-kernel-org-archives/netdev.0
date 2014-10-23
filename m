From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 06/14] net: dsa: Add support for hardware monitoring
Date: Wed, 22 Oct 2014 21:37:23 -0700
Message-ID: <CAGVrzcYjPJWai9bxkh+WRrEEAzBKBd-LQm7zDeeouxngr_v9SQ@mail.gmail.com>
References: <1414037002-25528-1-git-send-email-linux@roeck-us.net> <1414037002-25528-7-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414037002-25528-7-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-10-22 21:03 GMT-07:00 Guenter Roeck <linux@roeck-us.net>:
> Some Marvell switches provide chip temperature data.
> Add support for reporting it to the dsa infrastructure.
>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> ---
[snip]

> +/* hwmon support ************************************************************/
> +
> +#if defined(CONFIG_HWMON) || (defined(MODULE) && defined(CONFIG_HWMON_MODULE))

IS_ENABLED(CONFIG_HWMON)?

> +
> +static ssize_t temp1_input_show(struct device *dev,
> +                               struct device_attribute *attr, char *buf)
> +{
> +       struct dsa_switch *ds = dev_get_drvdata(dev);
> +       int temp, ret;
> +
> +       ret = ds->drv->get_temp(ds, &temp);
> +       if (ret < 0)
> +               return ret;
> +
> +       return sprintf(buf, "%d\n", temp * 1000);
> +}
> +static DEVICE_ATTR_RO(temp1_input);

You probably want the number of temperature sensors to come from the
switch driver, and support arbitrary number of temperature sensors?
--
Florian
