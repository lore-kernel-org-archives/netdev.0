From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix tuntap oversight
Date: Mon, 12 Apr 2004 00:15:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040412001551.05476658.davem@redhat.com>
References: <20040412065947.GC18810@net-ronin.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeremy Martin <martinjd@csc.uvic.ca>
In-Reply-To: <20040412065947.GC18810@net-ronin.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 11 Apr 2004 23:59:47 -0700
Jeremy Martin <martinjd@csc.uvic.ca> wrote:

> +static int tun_mac_addr(struct net_device *dev, void *p)
> +{
> +	struct sockaddr *addr=p;
> +	if (netif_running(dev))
> +		return -EBUSY;
> +	memcpy(dev->dev_addr, addr->sa_data,dev->addr_len);
> +	return 0;
> +}

This netif_running() check is not necessary, and in fact
wrong.

In fact, if ethernet drivers erroneously do this, this causes
them to fail to support the ALB bonding driver modes which
require on-the-fly MAC address changes while the interface is
up.
