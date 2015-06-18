From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 22/22] fjes: ethtool support
Date: Wed, 17 Jun 2015 21:10:20 -0400
Message-ID: <20150617211020.69cae194@uryu.home.lan>
References: <1434588359-25589-1-git-send-email-izumi.taku@jp.fujitsu.com>
	<1434588587-25655-1-git-send-email-izumi.taku@jp.fujitsu.com>
	<1434588587-25655-22-git-send-email-izumi.taku@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: platform-driver-x86@vger.kernel.org, dvhart@infradead.org,
	rkhan@redhat.com, alexander.h.duyck@redhat.com,
	netdev@vger.kernel.org, linux-acpi@vger.kernel.org
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Return-path: <platform-driver-x86-owner@vger.kernel.org>
In-Reply-To: <1434588587-25655-22-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 18 Jun 2015 09:49:47 +0900
Taku Izumi <izumi.taku@jp.fujitsu.com> wrote:

> +static void fjes_get_ethtool_stats(struct net_device *netdev,
> +		struct ethtool_stats *stats, u64 *data)
> +{
> +	struct fjes_adapter *adapter = netdev_priv(netdev);
> +	int i;
> +	char *p = NULL;

Although harmless, this initialization is unnecessary.


> +	for (i = 0; i < ARRAY_SIZE(fjes_gstrings_stats); i++) {
> +		p = (char *)adapter + fjes_gstrings_stats[i].stat_offset;
> +		data[i] = (fjes_gstrings_stats[i].sizeof_stat == sizeof(u64))
> +			? *(u64 *)p : *(u32 *)p;
