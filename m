From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v5 4/4] drivers: net: Add APM X-Gene SoC ethernet
 driver support.
Date: Thu, 05 Jun 2014 00:45:55 -0700 (PDT)
Message-ID: <20140605.004555.658378024391856482.davem@davemloft.net>
References: <1401737954-26152-1-git-send-email-isubramanian@apm.com>
	<1401737954-26152-5-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	patches-qTEPVZfXA3Y@public.gmane.org, rapatel-qTEPVZfXA3Y@public.gmane.org, kchudgar-qTEPVZfXA3Y@public.gmane.org
To: isubramanian-qTEPVZfXA3Y@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1401737954-26152-5-git-send-email-isubramanian-qTEPVZfXA3Y@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Date: Mon,  2 Jun 2014 12:39:14 -0700

> +	netdev_err(ndev, "LERR: %d ring_num: %d ", status, ring->num);
> +	switch (status) {
> +	case HBF_READ_DATA:
> +		netdev_err(ndev, "HBF read data error\n");
> +		break;

This is not really appropriate.

We have statistics like the ones you are incrementing in this
function as the mechanism people can use to learn what events
happened on an interface, and how many times they happened.

Therefore, emitting a log message for each one of those events too is
not necessary.

We don't emit a netdev_err() for every packet that the IPv4 stack
drops due to a bad checksum, for example.

Please get rid of this.

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
