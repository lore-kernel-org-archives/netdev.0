From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] hdlcdrv: fix divide error bug if bitrate is 0
Date: Fri, 19 May 2017 17:41:17 -0400 (EDT)
Message-ID: <20170519.174117.491042433043886205.davem@davemloft.net>
References: <CAAeHK+ya2sAtLmJ0VyP6e=13OXUw98dp1WdRFU=o5+xGFGPtbQ@mail.gmail.com>
        <20170519132146.744-1-firogm@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: t.sailer@alumni.ethz.ch, wharms@bfs.de, andreyknvl@google.com,
        linux-hams@vger.kernel.org, gregkh@linuxfoundation.org,
        netdev@vger.kernel.org
To: firogm@gmail.com
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20170519132146.744-1-firogm@gmail.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Firo Yang <firogm@gmail.com>
Date: Fri, 19 May 2017 21:21:46 +0800

> @@ -576,6 +576,10 @@ static int hdlcdrv_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
>  	case HDLCDRVCTL_CALIBRATE:
>  		if(!capable(CAP_SYS_RAWIO))
>  			return -EPERM;
> +		if (!netif_running(dev))
> +			return -ENODEV;
> +		if (!(s->par.bitrate > 0))
> +			return -EINVAL;

This test is so un-canonical and convoluted.

Please use something more straightforward.  I really think Alan
Cox's patch handled this more cleanly.  Make the test something
like "if (x <= 0) return -EINVAL;".

I also am not convinced about the netif_running() test and at
best it is a separate change from this divide by zero bug fix
so belongs in a separate patch.

Thank you.
