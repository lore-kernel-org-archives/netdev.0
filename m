From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [PATCH] (1/4) remove hashbin from irlan
Date: Mon, 18 Aug 2003 12:00:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818190046.GA6577@bougret.hpl.hp.com>
References: <20030818113936.205b5632.shemminger@osdl.org>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, irda-users@lists.sourceforge.net,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20030818113936.205b5632.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Aug 18, 2003 at 11:39:36AM -0700, Stephen Hemminger wrote:
> The locking in hashbin_delete is a problem since unregister_netdevice
> can't be called with locks held in 2.6.0-test3.
> 
> Replace it with simpler list macros.
> Insertion/deletion protected with RTNL semaphore, and read
> uses RCU.
> 
> Don't have client hardware to test, but load/unload works on SMP.

	Why don't you try the much simpler version :
----------------------------------------------
--- irlan_common.h1.c   Mon Aug 18 11:57:39 2003
+++ irlan_common.c      Mon Aug 18 11:58:25 2003
@@ -125,7 +125,7 @@ int __init irlan_init(void)
 
        IRDA_DEBUG(0, "%s()\n", __FUNCTION__ );
        /* Allocate master structure */
-       irlan = hashbin_new(HB_LOCK);   /* protect from /proc */
+       irlan = hashbin_new(HB_NOLOCK); /* network layer will protect us */
        if (irlan == NULL) {
                printk(KERN_WARNING "IrLAN: Can't allocate hashbin!\n");
                return -ENOMEM;
----------------------------------------------
	We would still need the RCU, but the overall patch would be
much simpler and safer IMHO. But it's up to you ;-)

	Have fun...

	Jean
