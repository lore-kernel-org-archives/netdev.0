From: Sergej Stepanov <Sergej.Stepanov@ids.de>
Subject: Re: [PATCH] using mii-bitbang on different processor ports
	-	update the booting-without-of.txt-file
Date: Fri, 09 Nov 2007 12:38:03 +0100
Message-ID: <1194608283.8755.10.camel@p60635-ste.ids.de>
References: <1194339117.3467.8.camel@p60635-ste.ids.de>
	 <20071106184649.GA5283@loki.buserror.net>
	 <1194442844.3571.14.camel@p60635-ste.ids.de>
	 <47336F9D.8060405@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, jgarzik@pobox.com
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares.ids.de ([213.144.29.131]:41414 "EHLO ares.ids.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751906AbXKILiH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Nov 2007 06:38:07 -0500
Received: from ares.ids.de (ares.ids.de [127.0.0.1])
	by ares.ids.de (PGP Universal) with ESMTP id 78B72F491AE
	for <netdev@vger.kernel.org>; Fri,  9 Nov 2007 12:38:03 +0100 (CET)
In-Reply-To: <47336F9D.8060405@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Donnerstag, den 08.11.2007, 14:20 -0600 schrieb Scott Wood: 
> Sergej Stepanov wrote:
> > If both mdio and mdc controlling pins are on the same processor port,
> > one resource should be used.
> > Otherwise, two resources are used: the 1-st - mdio, the 2-nd - mdc.
> 
> How about:
> The first reg resource is the I/O port register block on which MDIO 
> resides.  The second reg resource is the I/O port register block on 
> which MDC resides.  If there is only one reg resource, it is used for 
> both MDIO and MDC.
> 
Ok.

> We also need to change the reference to port C in fsl,mdio-pin and 
> fsl,mdc-pin.
Do you mean this:
   Currently defined compatibles:
   fsl,pq1-fec-mdio (reg is same as first resource of FEC device)
-> fsl,cpm2-mdio-bitbang (reg is port C registers)

   Properties for fsl,cpm2-mdio-bitbang:
-> fsl,mdio-pin : pin of port C controlling mdio data
-> fsl,mdc-pin : pin of port C controlling mdio clock

Right. But i thought it would be related to the example,
and than the reader gets the short comment about I/O ports.

Or the other variant would be:
--------------------
   iv) MDIO

   Currently defined compatibles:
   fsl,pq1-fec-mdio (reg is same as first resource of FEC device)
   fsl,cpm2-mdio-bitbang (reg is the I/O port register block(s))

   Properties for fsl,cpm2-mdio-bitbang:
   The first reg resource is the I/O port register block on which MDIO
   resides.  The second reg resource is the I/O port register block on
   which MDC resides.  If there is only one reg resource, it is used for
   both MDIO and MDC.
   fsl,mdio-pin : pin of chosen port for controlling mdio data
   fsl,mdc-pin : pin of chosen port for controlling mdio clock

   Example:
	mdio@10d40 {
	device_type = "mdio";
	compatible = "fsl,mpc8272ads-mdio-bitbang",
        	     "fsl,mpc8272-mdio-bitbang",
       		     "fsl,cpm2-mdio-bitbang";
	reg = <10d40 14>;
	#address-cells = <1>;
	#size-cells = <0>;
	fsl,mdio-pin = <12>;
	fsl,mdc-pin = <13>;
	};
-----------------

Regards
Sergej.

