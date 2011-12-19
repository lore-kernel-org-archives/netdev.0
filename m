From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 13/14] drivers/ieee802154: IEEE
	802.15.4 loopback driver
Date: Mon, 19 Dec 2011 14:49:57 -0500 (EST)
Message-ID: <20111219.144957.428523137343111592.davem@davemloft.net>
References: <20111219163117.GA13123@avtobot.cybertron>
	<1324312434-13151-13-git-send-email-alex.bluesman.smirnov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	alexander@Lenovo
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1324312434-13151-13-git-send-email-alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Mon, 19 Dec 2011 19:33:53 +0300

> +	unsigned int working:1;

Integer bit fields are troublesome, use a set of flags here, or if this
is likely to be the only set of state use a "bool" type.

> +		list_for_each_entry(dp, &priv->fake->list, list)
> +			if (dp != priv &&
> +			    dp->dev->phy->current_channel ==
> +					priv->dev->phy->current_channel)
> +				fakelb_hw_deliver(dp, skb);

Format the if() statement properly:

			if (dp != priv &&
			    (dp->dev->phy->current_channel ==
			     priv->dev->phy->current_channel))

And use braces around the top-level list traversal since the basic block is
taking up multiple lines.

> +static int
> +fakelb_hw_start(struct ieee802154_dev *dev) {
> +	struct fakelb_dev_priv *priv = dev->priv;
> +
> +	if (priv->working)
> +		return -EBUSY;
> +
> +	priv->working = 1;
> +
> +	return 0;
> +}

What prevents this "test and set" sequence from running in parallel with whatever
clears the ->working value and thus we end up losing the event?

> +	ieee->phy->channels_supported[6] |= 0x3ffc00;
> +
> +
> +	INIT_LIST_HEAD(&priv->list);

Excess empty line, there is no need for two of them, get rid of the
extra one.

------------------------------------------------------------------------------
Learn Windows Azure Live!  Tuesday, Dec 13, 2011
Microsoft is holding a special Learn Windows Azure training event for 
developers. It will provide a great way to learn Windows Azure and what it 
provides. You can attend the event by watching it streamed LIVE online.  
Learn more at http://p.sf.net/sfu/ms-windowsazure
