From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC 2.6.10 5/22] xfrm: Attempt to offload bundled xfrm_states
 for outbound xfrms
Date: Fri, 21 Jan 2005 15:20:45 -0800
Message-ID: <20050121152045.5c92ee05.davem@davemloft.net>
References: <20041230035000.13@ori.thedillows.org>
	<20041230035000.14@ori.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org, dave@thedillows.org
Return-path: <netdev-bounce@oss.sgi.com>
To: David Dillow <dave@thedillows.org>
In-Reply-To: <20041230035000.14@ori.thedillows.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 30 Dec 2004 03:48:35 -0500
David Dillow <dave@thedillows.org> wrote:

> +static void xfrm_accel_bundle(struct dst_entry *dst)
> +{
> +	struct xfrm_bundle_list bundle, *xbl, *tmp;
> +	struct net_device *dev = dst->dev;
> +	INIT_LIST_HEAD(&bundle.node);
> +
> +	if (dev && netif_running(dev) && (dev->features & NETIF_F_IPSEC)) {

netif_running() is only steady while the RTNL semaphore is held,
which is not necessarily true when xfrm_lookup() is invoked.
