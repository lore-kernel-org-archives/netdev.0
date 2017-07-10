From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] netdevice: add netdev_pub helper function
Date: Mon, 10 Jul 2017 09:04:07 +0100 (WEST)
Message-ID: <20170710.090407.1592129544725682024.davem@davemloft.net>
References: <20150612.142058.1085284048217032168.davem@davemloft.net>
        <20170710031959.7496-1-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jason@zx2c4.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170710031959.7496-1-Jason@zx2c4.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Mon, 10 Jul 2017 05:19:58 +0200

> Being able to utilize this makes code a lot simpler and cleaner. It's
> easier in many cases for drivers to pass around their private data
> structure, while occationally needing to dip into net_device, rather
> than the other way around, which results in tons of calls to netdev_priv
> in the top of every single function, which makes everything confusing
> and less clear. Additionally, this enables a "correct" way of doing such
> a thing, instead of having drivers attempt to reinvent the wheel and
> screw it up.
> 
> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>

I disagree.  Assuming one can go from the driver private to the netdev
object trivially is a worse assumption than the other way around, and
locks us into the current implementation of how the netdev and driver
private memory is allocated.

If you want to style your driver such that the private is passed
around instead of the netdev, put a pointer back to the netdev object
in your private data structure.

Which is exactly what the ioc3-eth driver ought to be doing.
