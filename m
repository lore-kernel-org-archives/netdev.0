From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] acenic - don't spin in hard_start_xmit when ring fills
Date: Thu, 16 Sep 2004 16:22:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040916162250.5b7cfa85.davem@davemloft.net>
References: <20040916161753.37254cbd@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jes@wildopensource.com, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040916161753.37254cbd@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 16 Sep 2004 16:17:53 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Running performance tests on the acenic, I noticed that the driver
> spins when the transmit ring gets full.  This might have been okay when
> CPU's were slower, but it isn't the right thing to do. Better to
> return TX_BUSY and let network scheduling handle it.

Acenic does completely lockless processing, are you sure you didn't
add a race or bug?

Also, NETDEV_TX_BUSY is not a valid return value for non-LLTX drivers.
>From Documentation/networking/netdevices.txt:

	o NETDEV_TX_LOCKED Locking failed, please retry quickly.
	  Only valid when NETIF_F_LLTX is set.
