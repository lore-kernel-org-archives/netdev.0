From: Roger Luethi <rl@hellgate.ch>
Subject: Re: [8/9][PATCH 2.6] Small fixes and clean-up
Date: Sun, 20 Jun 2004 00:23:19 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040619222319.GE3313@k3.hellgate.ch>
References: <20040615174956.GA11359@k3.hellgate.ch> <40D4AFE1.6020508@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <40D4AFE1.6020508@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 19 Jun 2004 17:28:01 -0400, Jeff Garzik wrote:
> In Linux lists of model names are discouraged.  It's not terribly bad in 
> via-rhine, but overall these things wind up getting patches quite often, 
> and become a maintenance annoyance.
> 
> It's up to you as maintainer, but I would recommend removing the string 
> completely.  For dmesg/printk purposes, the user only needs to know they 
> have a 'via-rhine' controller.

The reason I put that in is that lspci does not identify those chips
correctly (because models differ only by PCI revision, not PCI id)
and thus people get confused. But maybe I should rather file patches
against pci.ids. Okay, I think I'll remove the model names.

> >-	dev = alloc_etherdev(sizeof(*rp));
> >-	if (dev == NULL) {
> >+	dev = alloc_etherdev(sizeof(struct rhine_private));
> >+	if (!dev) {
> > 		rc = -ENOMEM;
> >-		printk(KERN_ERR "init_ethernet failed for card #%d\n",
> >-		       card_idx);
> >+		printk(KERN_ERR "alloc_etherdev failed\n");
> 
> this error message change seems like a step backwards... print out 
> pci_name() or _something_ to let the user know which card failed.

It is indeed. I plan to clean up all error messages together (there
are other issues like where dev->name is defined, what information is
useful, should use a bit mask instead of debug level, etc.).

Roger
