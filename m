From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/5] ethtool: cosmetics: enforce const-ness in
 ethtool_cmd_speed
Date: Sun, 17 Apr 2011 03:06:09 +0100
Message-ID: <1303005969.5282.912.camel@localhost>
References: <1303001651-4074-1-git-send-email-decot@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	ilon Greenstein <eilong@broadcom.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Decotigny <decot@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1303001651-4074-1-git-send-email-decot@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2011-04-16 at 17:54 -0700, David Decotigny wrote:
> The 'ep' argument of ethtool_cmd_speed is not altered: advertise it in
> protoype. +Indentation fix. Also add comments to advise using the
> ethtool_cmd_speed API to get/set the link speed.
> 
> Signed-off-by: David Decotigny <decot@google.com>
> ---
>  include/linux/ethtool.h |   14 ++++++++++----
>  1 files changed, 10 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index 9de3127..170439e 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -24,7 +24,10 @@ struct ethtool_cmd {
>  	__u32	cmd;
>  	__u32	supported;	/* Features this interface supports */
>  	__u32	advertising;	/* Features this interface advertises */
> -	__u16	speed;		/* The forced speed, 10Mb, 100Mb, gigabit */
> +	__u16	speed;	        /* The forced speed (lower bits): see
> +				 * SPEED_ macros below. Please use
> +				 * ethtool_cmd_speed()/_set() to
> +				 * access it */
[...]

Don't encourage use of the SPEED_* macros.  The speed is just a value in
units of Mbit/s.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
