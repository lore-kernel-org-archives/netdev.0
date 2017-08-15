From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 11/11] net: dsa: debugfs: add port vlan
Date: Tue, 15 Aug 2017 10:41:30 -0700
Message-ID: <25e9b8fb-5d60-93c7-4a15-64d5ff62aacd@gmail.com>
References: <20170814222242.10643-1-vivien.didelot@savoirfairelinux.com>
 <20170814222242.10643-12-vivien.didelot@savoirfairelinux.com>
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
In-Reply-To: <20170814222242.10643-12-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 08/14/2017 03:22 PM, Vivien Didelot wrote:
> Add a debug filesystem "vlan" entry to query a port's hardware VLAN
> entries through the .port_vlan_dump switch operation.
> 
> This is really convenient to query directly the hardware or inspect DSA
> or CPU links, since these ports are not exposed to userspace.
> 
> Here are the VLAN entries for a CPU port:
> 
>     # cat port5/vlan
>     vid 1
>     vid 42  pvid
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  net/dsa/debugfs.c | 33 +++++++++++++++++++++++++++++++++
>  1 file changed, 33 insertions(+)
> 
> diff --git a/net/dsa/debugfs.c b/net/dsa/debugfs.c
> index 98c5068d20da..b00942368d29 100644
> --- a/net/dsa/debugfs.c
> +++ b/net/dsa/debugfs.c
> @@ -286,6 +286,34 @@ static const struct dsa_debugfs_ops dsa_debugfs_tree_ops = {
>  	.read = dsa_debugfs_tree_read,
>  };
>  
> +static int dsa_debugfs_vlan_dump_cb(u16 vid, bool pvid, bool untagged,
> +				    void *data)
> +{
> +	struct seq_file *seq = data;
> +
> +	seq_printf(seq, "vid %d", vid);
> +	if (pvid)
> +		seq_puts(seq, "  pvid");
> +	if (untagged)
> +		seq_puts(seq, "  untagged");

Personal preference: could we just specify something like:

vid 1 (t)
vid 42 (u) pvid

to clearly show which VLAN is tagged/untagged?

Other than that:

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
