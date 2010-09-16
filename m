From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the pcmcia tree with the net tree
Date: Thu, 16 Sep 2010 12:31:44 +1000
Message-ID: <20100916123144.d34aa46f.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Joe Perches <joe@perches.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Dominik Brodowski <linux@dominikbrodowski.net>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dominik,

Today's linux-next merge of the pcmcia tree got a conflict in
drivers/net/pcmcia/smc91c92_cs.c between commit
636b8116d4e116eca1ac978f546b16fadfc15a6c ("drivers/net/pcmcia: Use
pr_<level> and netdev_<level>") from the net tree and commit
ba0ff6e64dab1a2492d88fdcc40b4eddabd8b451 ("pcmcia: split up
modify_configuration() into two fixup functions") from the pcmcia tree.

Just context changes.  I fixed it up (see below) and can carry the fix as
necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/pcmcia/smc91c92_cs.c
index 3d1c549,0af2fc8..0000000
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@@ -819,13 -792,10 +794,10 @@@ static int check_sig(struct pcmcia_devi
      }
  
      if (width) {
- 	    modconf_t mod = {
- 		    .Attributes = CONF_IO_CHANGE_WIDTH,
- 	    };
 -	    printk(KERN_INFO "smc91c92_cs: using 8-bit IO window.\n");
 +	    pr_info("using 8-bit IO window\n");
  
  	    smc91c92_suspend(link);
- 	    pcmcia_modify_configuration(link, &mod);
+ 	    pcmcia_fixup_iowidth(link);
  	    smc91c92_resume(link);
  	    return check_sig(link);
      }
