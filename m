From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix NETDEV_CHANGE notifier usage causing spurious
 arp flush
Date: Mon, 07 Jul 2014 21:20:34 -0700 (PDT)
Message-ID: <20140707.212034.2224956636540078311.davem@davemloft.net>
References: <1404275983-7908-1-git-send-email-loicp@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	timo.teras@iki.fi, jiri@resnulli.us
To: loicp@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404275983-7908-1-git-send-email-loicp@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Loic Prylli <loicp@google.com>
Date: Tue,  1 Jul 2014 21:39:43 -0700

> A bug was introduced in NETDEV_CHANGE notifier sequence causing the
> arp table to be sometimes spuriously cleared (including manual arp
> entries marked permanent), upon network link carrier changes.
> 
> The changed argument for the notifier was applied only to a single
> caller of NETDEV_CHANGE, missing among others netdev_state_change().
> So upon net_carrier events induced by the network, which are
> triggering a call to netdev_state_change(), arp_netdev_event() would
> decide whether to clear or not arp cache based on random/junk stack
> values (a kind of read buffer overflow).
> 
> Fixes: be9efd365328 ("net: pass changed flags along with NETDEV_CHANGE event")
> Fixes: 6c8b4e3ff81b ("arp: flush arp cache on IFF_NOARP change")
> Signed-off-by: Loic Prylli <loicp@google.com>

Applied, thanks.

We should probably make plain call_netdevice_notifiers() BUG if it is
invoked for NETDEV_CHANGE.
