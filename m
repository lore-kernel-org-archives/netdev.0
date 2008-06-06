From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 02/39] mv643xx_eth: trim unnecessary includes
Date: Fri, 6 Jun 2008 10:18:39 +0200
Message-ID: <20080606081839.GB5420@xi.wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-3-git-send-email-buytenh@wantstofly.org> <20080605110252.GA1059@farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:55295 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752011AbYFFITO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 04:19:14 -0400
Content-Disposition: inline
In-Reply-To: <20080605110252.GA1059@farnsworth.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 05, 2008 at 04:02:52AM -0700, Dale Farnsworth wrote:

> > -#include <linux/workqueue.h>
> 
> Isn't this needed for the definition of struct work and schedule_work()?
> 
> >  #include <linux/mii.h>
> > -
> >  #include <linux/mv643xx_eth.h>
> >  
> > -#include <asm/io.h>
> > -#include <asm/types.h>
> > -#include <asm/pgtable.h>
> > -#include <asm/system.h>
> > -#include <asm/delay.h>
> 
> Don't we still need this for udelay()?
> > -#include <asm/dma-mapping.h>
> 
> And this for dma_map_single, etc.
> 
> I didn't bother to check all the other includes being removed, but it
> seems you may have been a bit overly aggressive.

I just deleted everything that didn't make it stop compile, which I
admit is a bit overzealous. :)

I've attached a new patch below:
- linux/ip.h only contains struct iphdr/ip_auth_hdr/ip_esp_hdr/
  ip_comp_hdr and various IP options and IP TOS-related things,
  none of which we use.
- linux/bitops.h contains various BIT()/BIT_MASK()/etc defines and
  find_{first,next}_*bit()/ffs/for_each_bit(), none of which we use.
- asm/pgtable.h contains low-level page table handling functions and
  nothing of interest to the driver as far as I can tell.
- asm/delay.h isn't needed since we include linux/delay.h
- ditto for asm/dma-mapping.h

OK?



From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Sun Jun  1 00:54:05 CEST 2008
Subject: mv643xx_eth: trim unnecessary includes

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

Index: linux-2.6.26-rc5/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.6.26-rc5.orig/drivers/net/mv643xx_eth.c
+++ linux-2.6.26-rc5/drivers/net/mv643xx_eth.c
@@ -34,33 +34,25 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
  */
+
 #include <linux/init.h>
 #include <linux/dma-mapping.h>
 #include <linux/in.h>
-#include <linux/ip.h>
 #include <linux/tcp.h>
 #include <linux/udp.h>
 #include <linux/etherdevice.h>
-
-#include <linux/bitops.h>
 #include <linux/delay.h>
 #include <linux/ethtool.h>
 #include <linux/platform_device.h>
-
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/spinlock.h>
 #include <linux/workqueue.h>
 #include <linux/mii.h>
-
 #include <linux/mv643xx_eth.h>
-
 #include <asm/io.h>
 #include <asm/types.h>
-#include <asm/pgtable.h>
 #include <asm/system.h>
-#include <asm/delay.h>
-#include <asm/dma-mapping.h>
 
 static char mv643xx_driver_name[] = "mv643xx_eth";
 static char mv643xx_driver_version[] = "1.0";
