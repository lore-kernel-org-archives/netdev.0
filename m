From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 net-next v2 10/12] net: dsa: mv88e6xxx: iterate on
 compatible info
Date: Tue, 14 Jun 2016 22:38:44 +0300
Message-ID: <bdd3963d-2a38-78a8-7c74-c736f4a811e7@cogentembedded.com>
References: <20160614183153.32327-1-vivien.didelot@savoirfairelinux.com>
 <20160614183153.32327-11-vivien.didelot@savoirfairelinux.com>
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
In-Reply-To: <20160614183153.32327-11-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/14/2016 09:31 PM, Vivien Didelot wrote:

> With legacy probing, we cannot have a compatible info structure. We have
> to guess it. Instead of using only the first info structure of the info
> table, iterate over the compatible data.
>
> That way, the legacy code will support new compatible chips with
> different register access without requiring any code change.
>
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  drivers/net/dsa/mv88e6xxx.c | 21 ++++++++++++++++++++-
>  1 file changed, 20 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index 2f36d01..88c09d5 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -3668,6 +3668,25 @@ mv88e6xxx_smi_detect(struct device *dev, struct mii_bus *bus, int sw_addr,
>  	return ps;
>  }
>
> +static struct mv88e6xxx_priv_state *
> +mv88e6xxx_drv_detect(struct device *dev, struct mii_bus *bus, int sw_addr)
> +{
> +	struct mv88e6xxx_priv_state *ps = NULL;
> +	const struct mv88e6xxx_info *info;
> +	const struct of_device_id *id;
> +
> +	/* Iterate over compatible info to detect the chip */
> +	for (id = &mv88e6xxx_of_id_table[0]; id && id->data; ++id) {
> +		info = (const struct mv88e6xxx_info *)id->data;

    The explicit cast shouldn't be needed...

[...]

MBR, Sergei
