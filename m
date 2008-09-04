From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH 1/1 net-2.6] s2io: enabling VLAN tag stripping at driver initialization
Date: Thu, 4 Sep 2008 15:10:35 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7704330496@nekter>
References: <48C01EDB.7020001@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <jeff@garzik.org>, "Jay Vosburgh" <fubar@us.ibm.com>,
	"netdev" <netdev@vger.kernel.org>, "Lorandi" <rafaello@br.ibm.com>
To: "Breno Leitao" <leitao@linux.vnet.ibm.com>,
	"Rastapur Santosh" <santosh.rastapur@neterion.com>,
	"Sivakumar Subramani" <Sivakumar.Subramani@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:9749 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752910AbYIDTZs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2008 15:25:48 -0400
Content-class: urn:content-classes:message
In-Reply-To: <48C01EDB.7020001@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Breno,

When the chip comes out of reset, it's default setting is to strip the
vlan tag. So, in your patch, you will need to do this differently. The
vlan_strip_flag will have to be moved to the nic structure and
initialized there. 

> +	if (vlan_tag_strip)
> +		sp->vlan_strip_flag = 1;
> +	else 
> +		sp->vlan_strip_flag = 0;

Thanks,
Ram

> Actually s2io has a bug in VLAN support. VLAN doesn't work except if
> you'd opened the interface in promiscuous mode before.
> This happens because VLAN tag stripping is not enable by default (when
> the device is loaded). It is only enabled when the device leaves
> promiscuous mode.
> 
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
> 
> ---
> 
> diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
> index a2b0730..e656c80 100644
> --- a/drivers/net/s2io.c
> +++ b/drivers/net/s2io.c
> @@ -8206,6 +8206,14 @@ s2io_init_nic(struct pci_dev *pdev, const
struct
> pci_device_id *pre)
>  	/* Initialize device name */
>  	sprintf(sp->name, "%s Neterion %s", dev->name,
sp->product_name);
> 
> +	/* Initialize VLAN tag strip */
> +	if (vlan_tag_strip) {
> +		val64 = readq(&bar0->rx_pa_cfg);
> +		val64 |= RX_PA_CFG_STRIP_VLAN_TAG;
> +		writeq(val64, &bar0->rx_pa_cfg);
> +		vlan_strip_flag = 1;
> +	}
> +
>  	/*
>  	 * Make Link state as off at this point, when the Link change
>  	 * interrupt comes the state will be automatically changed to
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
