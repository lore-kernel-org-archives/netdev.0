From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 02/18] net: dsa: mv88e6xxx: Provide function for common
 port initialization
Date: Sat, 21 Mar 2015 15:41:02 -0700
Message-ID: <550DF37E.2090906@roeck-us.net>
References: <1426952815-4642-1-git-send-email-linux@roeck-us.net> <1426952815-4642-3-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:57872 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751767AbbCUWlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 18:41:19 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YZS50-003HEm-Eq
	for netdev@vger.kernel.org; Sat, 21 Mar 2015 22:41:18 +0000
In-Reply-To: <1426952815-4642-3-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/21/2015 08:46 AM, Guenter Roeck wrote:
> Provide mv88e6xxx_setup_port_common() for common port initialization.
> Currently only write Port 1 Control and VLAN configuration since
> this will be needed for hardware bridging. More can be added later
> if desired/needed.
>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> ---
>   drivers/net/dsa/mv88e6xxx.c | 39 +++++++++++++++++++++++++++++++++++++++
>   drivers/net/dsa/mv88e6xxx.h |  1 +
>   2 files changed, 40 insertions(+)
>
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index 6496beb..3c2cb45 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -700,6 +700,45 @@ int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
>   	return 0;
>   }
>
> +int mv88e6xxx_setup_port_common(struct dsa_switch *ds, int port)
> +{
> +	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
> +	int reg;
> +
> +	mutex_lock(&ps->smi_mutex);
> +
> +	/* Port Control 1: disable trunking.  Also, if this is the
> +	 * CPU port, enable learn messages to be sent to this port.
> +	 */
> +	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), 0x05,
> +				   dsa_is_cpu_port(ds, port) ? 0x8000 : 0x0000);

This fails to compile. It is fixed in a later commit which is why I didn't see it.
Too much reordering, I guess. Sorry for that.

Just a heads up; I'll wait for comments before resubmitting.

Guenter
