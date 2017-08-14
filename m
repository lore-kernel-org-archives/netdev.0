From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 04/11] net: dsa: debugfs: add tag_protocol
Date: Tue, 15 Aug 2017 00:42:27 +0200
Message-ID: <20170814224227.GA16885@lunn.ch>
References: <20170814222242.10643-1-vivien.didelot@savoirfairelinux.com>
 <20170814222242.10643-5-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Egil Hjelmeland <privat@egil-hjelmeland.no>,
        John Crispin <john@phrozen.org>,
        Woojung Huh <Woojung.Huh@microchip.com>,
        Sean Wang <sean.wang@mediatek.com>,
        Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Maxime Hadjinlian <maxime@devialet.com>,
        Chris Healy <cphealy@gmail.com>,
        Maxim Uvarov <muvarov@gmail.com>,
        Stefan Eichenberger <eichest@gmail.com>,
        Jason Cobham <jcobham@questertangent.com>,
        Juergen Borleis <jbe@pengutronix.de>,
        Tobias Waldekranz <tobias@waldekranz.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170814222242.10643-5-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 14, 2017 at 06:22:35PM -0400, Vivien Didelot wrote:
> Add a debug filesystem "tag_protocol" entry to query the switch tagging
> protocol through the .get_tag_protocol operation.
> 
>     # cat switch1/tag_protocol
>     EDSA
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  net/dsa/debugfs.c | 54 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 54 insertions(+)
> 
> diff --git a/net/dsa/debugfs.c b/net/dsa/debugfs.c
> index 5607efdb924d..30a732e86161 100644
> --- a/net/dsa/debugfs.c
> +++ b/net/dsa/debugfs.c
> @@ -109,6 +109,55 @@ static int dsa_debugfs_create_file(struct dsa_switch *ds, struct dentry *dir,
>  	return 0;
>  }
>  
> +static int dsa_debugfs_tag_protocol_read(struct dsa_switch *ds, int id,
> +					 struct seq_file *seq)
> +{
> +	enum dsa_tag_protocol proto;
> +
> +	if (!ds->ops->get_tag_protocol)
> +		return -EOPNOTSUPP;
> +
> +	proto = ds->ops->get_tag_protocol(ds);
> +
> +	switch (proto) {
> +	case DSA_TAG_PROTO_NONE:
> +		seq_puts(seq, "NONE\n");
> +		break;
> +	case DSA_TAG_PROTO_BRCM:
> +		seq_puts(seq, "BRCM\n");
> +		break;
> +	case DSA_TAG_PROTO_DSA:
> +		seq_puts(seq, "DSA\n");
> +		break;
> +	case DSA_TAG_PROTO_EDSA:
> +		seq_puts(seq, "EDSA\n");
> +		break;
> +	case DSA_TAG_PROTO_KSZ:
> +		seq_puts(seq, "KSZ\n");
> +		break;
> +	case DSA_TAG_PROTO_LAN9303:
> +		seq_puts(seq, "LAN9303\n");
> +		break;
> +	case DSA_TAG_PROTO_MTK:
> +		seq_puts(seq, "MTK\n");
> +		break;
> +	case DSA_TAG_PROTO_QCA:
> +		seq_puts(seq, "QCA\n");
> +		break;
> +	case DSA_TAG_PROTO_TRAILER:
> +		seq_puts(seq, "TRAILER\n");
> +		break;
> +	default:
> +		return -EINVAL;
> +	}

Hi Vivien

Minor nitpick. Rather than -EINVAL, how about seq_puts(seq, "Unknown - Please fix %s\n", __func__);

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
