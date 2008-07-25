From: Ben Dooks <ben-linux@fluff.org>
Subject: Re: [PATCH] dm9000: Support MAC address setting through platform
	data.
Date: Fri, 25 Jul 2008 10:05:30 +0100
Message-ID: <20080725090530.GA4318@fluff.org.uk>
References: <200807231741.53011.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ben Dooks <ben-linux@fluff.org>
To: Laurent Pinchart <laurentp@cse-semaphore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:54297 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753207AbYGYJFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 05:05:36 -0400
Content-Disposition: inline
In-Reply-To: <200807231741.53011.laurentp@cse-semaphore.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 23, 2008 at 05:41:52PM +0200, Laurent Pinchart wrote:
> The dm9000 driver reads the chip's MAC address from the attached EEPROM. When
> no EEPROM is present, or when the MAC address is invalid, it falls back to
> reading the address from the chip.
> 
> This patch lets platform code set the desired MAC address through platform
> data.

I belive we've had discussions about this before on the subject
as this is generally down to broken boot-loader behaviour.

Would people have objections to passing the mac address in on the
command line and having the driver initialise it from there? Are
there any other ethernet drivers out there with the same problem?

I've added some notes on the patch anyway.
 
> Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
> ---
>  drivers/net/dm9000.c   |    3 +++
>  include/linux/dm9000.h |    1 +
>  2 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
> index 864295e..6bc8924 100644
> --- a/drivers/net/dm9000.c
> +++ b/drivers/net/dm9000.c
> @@ -716,6 +716,11 @@ dm9000_probe(struct platform_device *pdev)
>  	for (i = 0; i < 6; i += 2)
>  		dm9000_read_eeprom(db, i / 2, ndev->dev_addr+i);
>  
> +	if (!is_valid_ether_addr(ndev->dev_addr) && pdata != NULL) {
> +		mac_src = "platform data";
> +		memcpy(ndev->dev_addr, pdata->dev_addr, 6);
> +	}
> +
>  	if (!is_valid_ether_addr(ndev->dev_addr)) {
>  		/* try reading from mac */
>  		
> diff --git a/include/linux/dm9000.h b/include/linux/dm9000.h
> index a375046..4fb49a4 100644
> --- a/include/linux/dm9000.h
> +++ b/include/linux/dm9000.h
> @@ -26,6 +26,7 @@
>  
>  struct dm9000_plat_data {
>  	unsigned int	flags;
> +	unsigned char	dev_addr[6];

how about unsigned char *mac_addr, so that you can detect
if the address has not been passed in easily. dev_addr is
not really descriptive enough as a name.

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
