From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 5/8] net: dsa: add tagging ops to port
Date: Fri, 29 Sep 2017 12:24:42 -0700
Message-ID: <642468a1-2083-3b00-63ab-934e54499e4c@gmail.com>
References: <20170929183635.8122-1-vivien.didelot@savoirfairelinux.com>
 <20170929183635.8122-6-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170929183635.8122-6-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/29/2017 11:36 AM, Vivien Didelot wrote:
> The DSA tagging protocol operations are specific to each CPU port,
> thus the dsa_device_ops pointer belongs to the dsa_port structure.
> 
> From now on assign a slave's xmit copy from its CPU port tagging
> operations. This will ease the future support for multiple CPU ports.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  include/net/dsa.h  | 3 +++
>  net/dsa/dsa2.c     | 1 +
>  net/dsa/dsa_priv.h | 2 +-
>  net/dsa/legacy.c   | 1 +
>  net/dsa/slave.c    | 3 +--
>  5 files changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/include/net/dsa.h b/include/net/dsa.h
> index 8dee216a5a9b..6cd36dcb65e1 100644
> --- a/include/net/dsa.h
> +++ b/include/net/dsa.h
> @@ -189,6 +189,9 @@ struct dsa_port {
>  	 * Original copy of the master netdev ethtool_ops
>  	 */
>  	const struct ethtool_ops *orig_ethtool_ops;
> +
> +	/* CPU port tagging operations used by master or slave devices */
> +	const struct dsa_device_ops *tag_ops;

You might actually want to move this up in the dsa_port structure in
order to keep being in the first cacheline (you can use pahole -C
dsa_port vmlinux).

dsa_switch_tree is currently a 56 bytes structure, thus fitting in a 64b
cache line, but dsa_port is 80bytes, and the hot-path are in the second
cacheline, so less efficient.
-- 
Florian
