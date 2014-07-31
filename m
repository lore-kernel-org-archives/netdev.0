From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 2/3] ethtool: Add support for DMA buffer
 settings
Date: Wed, 30 Jul 2014 17:53:06 -0700 (PDT)
Message-ID: <20140730.175306.483788306179792581.davem@davemloft.net>
References: <1406634039-15030-1-git-send-email-_govind@gmx.com>
	<1406634039-15030-3-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, netdev@vger.kernel.org, ssujith@cisco.com,
	benve@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38015 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752883AbaGaAxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 20:53:07 -0400
In-Reply-To: <1406634039-15030-3-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Tue, 29 Jul 2014 17:10:38 +0530

> @@ -440,6 +440,20 @@ struct ethtool_ringparam {
>  };
>  
>  /**
> + * struct ethtool_buffparam - DMA buffer parameters
> + * @rx_copybreak_cur: current receive DMA buff rx_copybreak.
> + * @rx_copybreak_min: min rx_copybreak set by driver.
> + * @rx_copybreak_max: Max rx_copybreak set by driver.
> + * @reserved: reserve room for future use.
> + */
> +struct ethtool_buffparam {
> +	__u32	cmd;
> +	__u32	rx_copybreak_cur;
> +	__u32	rx_copybreak_max;
> +	__u8	reserved[84];
> +};

I don't understand the reasoning behind this reserved field.

You can't use it to add more fields later, because right now
we'll let the user put any garbage there and thus if you add
more fields that garbage from older apps would be interpreted
as one of the new values.

Largely we have not been adding reserved fields to new ethtool
structures, and this is the primary reason I guess.

It's a shame that when we want to add a new 32-bit knob we have
to add an entire new struct.

We have ethtool_value, but that's only good for one knob at a time and
we have to allocate an entire new ethtool command value for each such
knob.

I really don't know what the recommend here.

However I wonder what value that "max" thing has, I think setting the
value to infinity is just fine, it just means every packet will be
copied.

So if we remove the 'max', we just have the copybreak itself, and you
can therefore use ethtool_value and allocate the ethtool command
numbers.

What do you think?
