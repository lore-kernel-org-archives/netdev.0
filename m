From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: Re: [PATCH] smc91c92_cs: use request_firmware
Date: Mon, 28 Jul 2008 11:07:53 +0200
Message-ID: <20080728090753.GA12080@isilmar.linta.de>
References: <1217170341.3537.9.camel@jaswinder.satnam> <20080728082814.GA4708@isilmar.linta.de> <1217235775.6407.3.camel@jaswinder.satnam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>, dahinds@users.sourceforge.net,
	becker@scyld.com, x-csrdh@jcu.edu.au, erik@vt.edu,
	Jeff Garzik <jeff@garzik.org>, netdev <netdev@vger.kernel.org>,
	David Woodhouse <dwmw2@infradead.org>
To: Jaswinder Singh <jaswinder@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar.linta.de ([213.133.102.198]:60400 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751970AbYG1JHz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jul 2008 05:07:55 -0400
Content-Disposition: inline
In-Reply-To: <1217235775.6407.3.camel@jaswinder.satnam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, Jul 28, 2008 at 02:32:54PM +0530, Jaswinder Singh wrote:
> On Mon, 2008-07-28 at 10:28 +0200, Dominik Brodowski wrote:
> > > +static int osi_load_firmware(struct pcmcia_device *link)
> > > +{
> > > +	struct platform_device *pdev;
> > > +	const struct firmware *fw;
> > > +	const char fw_name[] = "ositech/Xilinx7OD.bin"; 
> > > +	int i, err;
> > > + 
> > > +	pdev = platform_device_register_simple("ositech", 0, NULL, 0);
> > 
> > Why do we need a platform_device here? Can't we just use the pcmcia device
> > (so &link->dev) here?
> > 
> 
> Thanks for pointing it out, I was searching for it.
> 
> Here is the fix:
> 
> diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
> index 03f9be9..43d8e23 100644
> --- a/drivers/net/pcmcia/smc91c92_cs.c
> +++ b/drivers/net/pcmcia/smc91c92_cs.c
> @@ -43,7 +43,6 @@
>  #include <linux/mii.h>
>  #include <linux/jiffies.h>
>  #include <linux/firmware.h>
> -#include <linux/platform_device.h>
>  
>  #include <pcmcia/cs_types.h>
>  #include <pcmcia/cs.h>
> @@ -794,18 +793,11 @@ static int osi_config(struct pcmcia_device *link)
>  
>  static int osi_load_firmware(struct pcmcia_device *link)
>  {
> -	struct platform_device *pdev;
>  	const struct firmware *fw;
>  	const char fw_name[] = "ositech/Xilinx7OD.bin"; 
>  	int i, err;
>   
> -	pdev = platform_device_register_simple("ositech", 0, NULL, 0);
> -	if (IS_ERR(pdev)) {
> -		printk(KERN_ERR "Failed to register platform device ositech\n");
> -		return IS_ERR(pdev);
> -	}
> -	err = request_firmware(&fw, fw_name, &pdev->dev);
> -	platform_device_unregister(pdev);
> +	err = request_firmware(&fw, fw_name, &link->dev);
>  	if (err) {
>  		printk(KERN_ERR "Failed to load firmware \"%s\"\n",
>  		       fw_name);
> 
> You can check updated patch from :-
> 
> http://git.infradead.org/users/jaswinder/firm-jsr-2.6.git

for the pcmcia aspects of this patch:
Acked-by: Dominik Brodowski <linux@dominikbrodowski.net>

Thanks!

	Dominik
