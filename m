From: Crutcher Dunnavant <crutcher@eng.ua.edu>
Subject: proposed changes to init_*dev() for GFP_DMA
Date: Tue, 2 Jul 2002 14:36:54 -0500
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020702143654.A9903@monket.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

Hello all.

For the 2.5 tree,

I'm wondering if there would be support for extending the
underlying init_*dev() -> init_netdev() interfaces, so that
there is a way to pass in the GFP_DMA alloc flag, or any other
flag, if needed for the private memory to be kmalloced for
dev->priv? This would allow more drivers to use the same
interface.

Basicaly, I'm thinking something like:

struct net_device *init_etherdev(struct net_device *dev, int sizeof_priv, int flags);

/* for regualr devices */
dev = init_etherdev(NULL, sizeof(struct foo_priv), GFP_KERNEL);

or 

/* for DMA devices */
dev = init_etherdev(NULL, sizeof(struct foo_priv), GFP_KERNEL | GFP_DMA);

-- 
Crutcher Dunnavant <crutcher+spam@eng.ua.edu>
ECSS System Hacker / UA COE CS Senior
