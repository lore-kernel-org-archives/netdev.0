From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 04/11] net: dsa: debugfs: add tag_protocol
Date: Tue, 15 Aug 2017 10:31:30 -0700
Message-ID: <43f9f204-a3aa-a194-90d8-1f8a42fdd83d@gmail.com>
References: <20170814222242.10643-1-vivien.didelot@savoirfairelinux.com>
 <20170814222242.10643-5-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
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
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170814222242.10643-5-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 08/14/2017 03:22 PM, Vivien Didelot wrote:
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

Might be worth adding a helper function: does dsa_tag_protocol_to_str()
which is in include/net/dsa.h so it's easy to keep in sync when new
taggers are added, then you can just do:

	seq_puts(seq, dsa_tag_protocol_to_str(proto));

and/or use a temporary buffer for adding the trailing newline.
-- 
Florian
