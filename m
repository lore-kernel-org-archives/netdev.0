From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 net-next v2 08/12] net: dsa: mv88e6xxx: read switch ID
 from info
Date: Tue, 14 Jun 2016 21:50:28 +0300
Message-ID: <fea82e7e-7c1d-baac-8a91-07cd94b13b6c@cogentembedded.com>
References: <20160614183153.32327-1-vivien.didelot@savoirfairelinux.com>
 <20160614183153.32327-9-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160614183153.32327-9-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 06/14/2016 09:31 PM, Vivien Didelot wrote:

> Retrieve the info structure of the compatible of device in the new probe
> function, in order to know how to access the switch ID register.
>
> That way, a compatible info can be used to describe how to access the
> switch registers on models with different registers layout or addressing
> modes.
>
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  drivers/net/dsa/mv88e6xxx.c | 11 ++++++++++-
>  1 file changed, 10 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index 8c39dd0..8ac9f9a 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
[...]
> @@ -3745,6 +3746,8 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
>  {
>  	struct device *dev = &mdiodev->dev;
>  	struct device_node *np = dev->of_node;
> +	const struct of_device_id *of_id;
> +	const struct mv88e6xxx_info *info;
>  	struct mv88e6xxx_priv_state *ps;
>  	int id, prod_num, rev;
>  	u32 eeprom_len;
> @@ -3759,7 +3762,13 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
>  	ps->sw_addr = mdiodev->addr;
>  	mutex_init(&ps->smi_mutex);
>
> -	id = mv88e6xxx_reg_read(ps, REG_PORT(0), PORT_SWITCH_ID);
> +	of_id = of_match_node(mv88e6xxx_of_id_table, np);

    You could use of_device_get_match_data() here.

> +	if (!of_id)
> +		return -EINVAL;
> +
> +	info = (const struct mv88e6xxx_info *)of_id->data;

    Pointer casts from 'void *' are automatic.

[...]

MBR, Sergei
