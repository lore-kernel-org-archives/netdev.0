From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: [patch] usb: pegasus: cleanup a couple conditions
Date: Fri, 23 Dec 2011 18:15:29 +0200 (EET)
Message-ID: <alpine.DEB.2.02.1112231813001.6533@bender.nucleusys.com>
References: <20111223104436.GA8592@elgon.mountain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Petko Manolov <petkan@users.sourceforge.net>,
	Greg Kroah-Hartman <gregkh@suse.de>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lan.nucleusys.com ([78.83.248.164]:53810 "EHLO
	zztop.nucleusys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754461Ab1LWQyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 11:54:03 -0500
In-Reply-To: <20111223104436.GA8592@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Once i thought 'loopback' may have other significant bits.  Since it 
doesn't look likely anymore i guess the patch is OK.


cheers,
Petko



On Fri, 23 Dec 2011, Dan Carpenter wrote:

> We recently made loopback a bool type instead of an int, so the bitwise
> AND is redundent.
>
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>
> diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
> index 908b427..5d99b8c 100644
> --- a/drivers/net/usb/pegasus.c
> +++ b/drivers/net/usb/pegasus.c
> @@ -517,7 +517,7 @@ static inline int reset_mac(pegasus_t *pegasus)
> 	for (i = 0; i < REG_TIMEOUT; i++) {
> 		get_registers(pegasus, EthCtrl1, 1, &data);
> 		if (~data & 0x08) {
> -			if (loopback & 1)
> +			if (loopback)
> 				break;
> 			if (mii_mode && (pegasus->features & HAS_HOME_PNA))
> 				set_register(pegasus, Gpio1, 0x34);
> @@ -561,7 +561,7 @@ static int enable_net_traffic(struct net_device *dev, struct usb_device *usb)
> 		data[1] |= 0x10;	/* set 100 Mbps */
> 	if (mii_mode)
> 		data[1] = 0;
> -	data[2] = (loopback & 1) ? 0x09 : 0x01;
> +	data[2] = loopback ? 0x09 : 0x01;
>
> 	memcpy(pegasus->eth_regs, data, sizeof(data));
> 	ret = set_registers(pegasus, EthCtrl0, 3, data);
>
