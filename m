From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the trivial tree with the net tree
Date: Wed, 24 Feb 2010 16:21:42 +1100
Message-ID: <20100224162142.b0c572ed.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Adam Buchbinder <adam.buchbinder@gmail.com>,
	Joe Perches <joe@perches.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jiri,

Today's linux-next merge of the trivial tree got a conflict in
drivers/net/typhoon.c between commit
0bc88e4af07621bc4b84477374745d01a470e85d ("drivers/net/typhoon.c: Use (pr|
netdev)_<level> macro helpers") from the net tree and commit
a089377f29d3af0f62f3bdc6db0c5042513fc3f3 ("Fix misspelling of "truly" in
a label") from the trivial tree.

Just context changes.  I fixed it up (see below) and can carry the fix as
necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/typhoon.c
index 38c2161,d1a8068..0000000
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@@ -2098,8 -2111,9 +2098,8 @@@ typhoon_tx_timeout(struct net_device *d
  	struct typhoon *tp = netdev_priv(dev);
  
  	if(typhoon_reset(tp->ioaddr, WaitNoSleep) < 0) {
 -		printk(KERN_WARNING "%s: could not reset in tx timeout\n",
 -					dev->name);
 +		netdev_warn(dev, "could not reset in tx timeout\n");
- 		goto truely_dead;
+ 		goto truly_dead;
  	}
  
  	/* If we ever start using the Hi ring, it will need cleaning too */
@@@ -2107,8 -2121,9 +2107,8 @@@
  	typhoon_free_rx_rings(tp);
  
  	if(typhoon_start_runtime(tp) < 0) {
 -		printk(KERN_ERR "%s: could not start runtime in tx timeout\n",
 -					dev->name);
 +		netdev_err(dev, "could not start runtime in tx timeout\n");
- 		goto truely_dead;
+ 		goto truly_dead;
          }
  
  	netif_wake_queue(dev);
