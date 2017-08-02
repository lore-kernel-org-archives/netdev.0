From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net 6/7] netvsc: Initialize 64-bit stats seqcount
Date: Tue, 1 Aug 2017 19:42:42 -0700
Message-ID: <20170801194242.0d79787d@xeon-e3>
References: <20170801191113.8754-1-f.fainelli@gmail.com>
        <20170801191113.8754-8-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>,
        open list <linux-kernel@vger.kernel.org>, edumazet@google.com,
        "open list:Hyper-V CORE AND DRIVERS" <devel@linuxdriverproject.org>,
        davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170801191113.8754-8-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue,  1 Aug 2017 12:11:12 -0700
Florian Fainelli <f.fainelli@gmail.com> wrote:

> On 32-bit hosts and with CONFIG_DEBUG_LOCK_ALLOC we should be seeing a
> lockdep splat indicating this seqcount is not correctly initialized, fix
> that. In commit 6c80f3fc2398 ("netvsc: report per-channel stats in
> ethtool statistics") netdev_alloc_pcpu_stats() was removed in favor of
> open-coding the 64-bits statistics, except that u64_stats_init() was
> missed.
> 
> Fixes: 6c80f3fc2398 ("netvsc: report per-channel stats in ethtool statistics")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/hyperv/netvsc.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
> index 0a9167dd72fb..96f90c75d1b7 100644
> --- a/drivers/net/hyperv/netvsc.c
> +++ b/drivers/net/hyperv/netvsc.c
> @@ -1302,6 +1302,8 @@ int netvsc_device_add(struct hv_device *device,
>  		struct netvsc_channel *nvchan = &net_device->chan_table[i];
>  
>  		nvchan->channel = device->channel;
> +		u64_stats_init(&nvchan->tx_stats.syncp);
> +		u64_stats_init(&nvchan->rx_stats.syncp);
>  	}
>  
>  	/* Enable NAPI handler before init callbacks */


Looks good, thanks. 32 bit guests are still supported but rarely tested.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
