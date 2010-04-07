From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the pcmcia tree with the net tree
Date: Wed, 7 Apr 2010 14:17:07 +1000
Message-ID: <20100407141707.e80c8768.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexander Kurz <linux@kbdbabel.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Dominik Brodowski <linux@dominikbrodowski.net>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dominik,

Today's linux-next merge of the pcmcia tree got a conflict in
drivers/net/pcmcia/3c589_cs.c between commit
f64e96973a1fa885ce6e4f7e3fdbae83de98fcab ("net/pcmcia/3c589_cs: using
netdev_info and friends where appropriate") from the net tree and commits
cbd8ca0260b78f3b4157dc8ff23edbd211c4eef5 ("pcmcia: re-work
pcmcia_request_irq()") and cc25a704447fad12205ca8c7c42d6bba1c1590b0
("pcmcia: dev_node removal (drivers with unregister_netdev check)") from
the pcmcia tree.

Most of these conflicts are just due to unrelated white space changes in
the net tree commit.  I fixed it up (see below) and can carry the fix as
necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/pcmcia/3c589_cs.c
index 580977f,5ab589d..0000000
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@@ -129,13 -106,12 +129,12 @@@ enum RxFilter 
  
  struct el3_private {
  	struct pcmcia_device	*p_dev;
- 	dev_node_t		node;
 -    /* For transceiver monitoring */
 -    struct timer_list	media;
 -    u16			media_status;
 -    u16			fast_poll;
 -    unsigned long	last_irq;
 -    spinlock_t		lock;
 +	/* For transceiver monitoring */
 +	struct timer_list	media;
 +	u16			media_status;
 +	u16			fast_poll;
 +	unsigned long		last_irq;
 +	spinlock_t		lock;
  };
  
  static const char *if_names[] = { "auto", "10baseT", "10base2", "AUI" };
@@@ -301,8 -274,8 +297,8 @@@ static int tc589_config(struct pcmcia_d
      ret = pcmcia_request_configuration(link, &link->conf);
      if (ret)
  	    goto failed;
 -	
 +
-     dev->irq = link->irq.AssignedIRQ;
+     dev->irq = link->irq;
      dev->base_addr = link->io.BasePort1;
      ioaddr = dev->base_addr;
      EL3WINDOW(0);
@@@ -335,8 -308,7 +331,7 @@@
  	dev->if_port = if_port;
      else
  	printk(KERN_ERR "3c589_cs: invalid if_port requested\n");
 -    
 +
-     link->dev_node = &lp->node;
      SET_NETDEV_DEV(dev, &link->dev);
  
      if (register_netdev(dev) != 0) {
@@@ -344,15 -316,13 +339,12 @@@
  	goto failed;
      }
  
-     strcpy(lp->node.dev_name, dev->name);
- 
 -    printk(KERN_INFO "%s: 3Com 3c%s, io %#3lx, irq %d, "
 -	   "hw_addr %pM\n",
 -	   dev->name, (multi ? "562" : "589"), dev->base_addr, dev->irq,
 -	   dev->dev_addr);
 -    printk(KERN_INFO "  %dK FIFO split %s Rx:Tx, %s xcvr\n",
 -	   (fifo & 7) ? 32 : 8, ram_split[(fifo >> 16) & 3],
 -	   if_names[dev->if_port]);
 +    netdev_info(dev, "3Com 3c%s, io %#3lx, irq %d, hw_addr %pM\n",
 +		(multi ? "562" : "589"), dev->base_addr, dev->irq,
 +		dev->dev_addr);
 +    netdev_info(dev, "  %dK FIFO split %s Rx:Tx, %s xcvr\n",
 +		(fifo & 7) ? 32 : 8, ram_split[(fifo >> 16) & 3],
 +		if_names[dev->if_port]);
      return 0;
  
  failed:
