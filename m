From: Thomas Munck Steenholdt <tmus@tmus.dk>
Subject: Re: [PATCH] 2.6.3 pcnet32.c fix link reporting for non-mii devices
Date: Tue, 24 Feb 2004 06:31:40 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <403AE1BC.2090707@tmus.dk>
References: <200402202232.i1KMWqD07369@DYN318364BLD.beaverton.ibm.com> <4037D42C.4030909@tmus.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Don Fry <brazilnut@us.ibm.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <4037D42C.4030909@tmus.dk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Munck Steenholdt wrote:
  > Hi again!
> 
> Decided to do some research and get this thing implemented right!
> I've created a new patch against the 2.6.3-bk3 version of pcnet32.c
> 
> What this patch does is that in the event that mii is not supported, 
> link status is read directly from device's lnktst bcr register.
> 
> Works without any problem with the virtual nic under vmware. So if all 
> the other non-mii pcnet32 devices have the link status register in the 
> same place, things should be just fine!
> 
> Could you please test this and let me know what you think?
> 
> Best regards
> 
> Thomas
> 
> 
> ------------------------------------------------------------------------
> 
> --- drivers/net/pcnet32.c.tmus	2004-02-19 15:24:31.238513096 +0100
> +++ drivers/net/pcnet32.c	2004-02-19 15:27:28.265600888 +0100
> @@ -1644,7 +1644,9 @@
>  	case ETHTOOL_GLINK: {
>  		struct ethtool_value edata = {ETHTOOL_GLINK};
>  		spin_lock_irq(&lp->lock);
> -		edata.data = mii_link_ok(&lp->mii_if);
> +		if(lp->mii) edata.data = mii_link_ok(&lp->mii_if);
> +                /* read the LNKTST BCR register for link status on non-mii capable devices */
> +                else edata.data = (lp->a.read_bcr(ioaddr,4) != 0xc0);
>  		spin_unlock_irq(&lp->lock);
>  		if (copy_to_user(useraddr, &edata, sizeof(edata)))
>  			return -EFAULT;

Hi there

If this is a repost, then i'm sorry! I didn't get it myself!

I'd like to make sure we get this patched in the pcnet32 driver!

If you'll need me to do the patch for another version of the pcnet32.c 
file, let me know!

Best regards

Thomas
