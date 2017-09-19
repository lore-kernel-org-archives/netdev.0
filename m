From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 05/12] net: dsa: b53: Use a macro to define I/O
 operations
Date: Tue, 19 Sep 2017 12:53:51 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD007A003@AcuExch.aculab.com>
References: <20170918214128.27896-1-f.fainelli@gmail.com>
 <20170918214128.27896-6-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "andrew@lunn.ch" <andrew@lunn.ch>,
        "vivien.didelot@savoirfairelinux.com"
        <vivien.didelot@savoirfairelinux.com>
To: 'Florian Fainelli' <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.185]:60845 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750823AbdISMx6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 08:53:58 -0400
In-Reply-To: <20170918214128.27896-6-f.fainelli@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli
> Sent: 18 September 2017 22:41
> Instead of repeating the same pattern: acquire mutex, read/write, release
> mutex, define a macro: b53_build_op() which takes the type (read|write), I/O
> size, and value (scalar or pointer). This helps with fixing bugs that could
> exit (e.g: missing barrier, lock etc.).
....
> +#define b53_build_op(type, op_size, val_type)	\
> +static inline int b53_##type##op_size(struct b53_device *dev, u8 page,		\
> +				      u8 reg, val_type val)			\
> +{										\
> +	int ret;								\
> +										\
> +	mutex_lock(&dev->reg_mutex);						\
> +	ret = dev->ops->type##op_size(dev, page, reg, val);			\
> +	mutex_unlock(&dev->reg_mutex);						\
> +										\
> +	return ret;								\
>  }

Why separate the 'type' and 'op_size' arguments since they
are always pasted together?

	David
