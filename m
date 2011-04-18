From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH V14 4/4] ptp: Added a clock driver for the National
 Semiconductor PHYTER.
Date: Mon, 18 Apr 2011 21:57:25 +0100
Message-ID: <1303160245.2857.60.camel@bwh-desktop>
References: <cover.1303107532.git.richard.cochran@omicron.at>
	 <1728ffb5735c2a04876a69ad55427c4e7b5a1bd7.1303107532.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Arnd Bergmann <arnd@arndb.de>,
	Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>,
	John Stultz <john.stultz@linaro.org>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Rodolfo Giometti <giometti@linux.it>,
	Thomas Gleixner <tglx@linutronix.de>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Mike Frysinger <vapier@gentoo.org>,
	Paul Mackerras <paulus@samba.org>,
	Russell King <linux@arm.linux.org.uk>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1728ffb5735c2a04876a69ad55427c4e7b5a1bd7.1303107532.git.richard.cochran@omicron.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-04-18 at 08:30 +0200, Richard Cochran wrote:
> This patch adds support for the PTP clock found on the DP83640.
> The basic clock operations and one external time stamp have
> been implemented.
[...]
> --- /dev/null
> +++ b/drivers/net/phy/dp83640.c
[...]
> +static int match(struct sk_buff *skb, unsigned int type, struct rxts *rxts)
> +{
> +	u16 *seqid;

Should be __be16 *, and similarly for the casts.

> +	u8 *msgtype, *data = skb_mac_header(skb);
> +
> +	/* check sequenceID, messageType, 12 bit hash of offset 20-29 */
> +	/* We assume that the IPv4 header has no options. */

Does the hardware definitely not timestamp received packets with IP
options?

> +	switch (type) {
> +	case PTP_CLASS_V1_IPV4:
> +		msgtype = data + 42 + 32;
> +		seqid = (u16 *)(data + 42 + 30);
> +		break;
> +	case PTP_CLASS_V1_IPV6:
> +		msgtype = data + 62 + 32;
> +		seqid = (u16 *)(data + 62 + 30);
> +		break;
> +	case PTP_CLASS_V2_IPV4:
> +		msgtype = data + 42 + 0;
> +		seqid = (u16 *)(data + 42 + 30);
> +		break;
> +	case PTP_CLASS_V2_IPV6:
> +		msgtype = data + 62 + 0;
> +		seqid = (u16 *)(data + 62 + 30);
> +		break;
> +	case PTP_CLASS_V2_L2:
> +		msgtype = data + 14 + 0;
> +		seqid = (u16 *)(data + 14 + 30);
> +		break;
> +	case PTP_CLASS_V2_VLAN:
> +		msgtype = data + 18 + 0;
> +		seqid = (u16 *)(data + 18 + 30);
> +		break;
[...]

Would be better without the magic numbers.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
