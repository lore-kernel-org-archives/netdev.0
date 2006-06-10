From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFT] Realtek 8168 ethernet support
Date: Sat, 10 Jun 2006 14:05:23 +0200
Message-ID: <20060610120523.GA24288@electric-eye.fr.zoreil.com>
References: <20060601200200.A0E0689D05D@zog.reactivated.net> <20060608143133.7e36a0b7.rdunlap@xenotime.net> <4488DF85.3090901@garzik.org> <20060609183358.GA5835@electric-eye.fr.zoreil.com> <4489C290.6020705@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Randy.Dunlap" <rdunlap@xenotime.net>,
	Daniel Drake <dsd@gentoo.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:28565 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1751495AbWFJMJZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Jun 2006 08:09:25 -0400
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <4489C290.6020705@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik <jeff@garzik.org> :
> Francois Romieu wrote:
> >Jeff Garzik <jeff@garzik.org> :
> >>Randy.Dunlap wrote:
> >>>Conversely, any reason to use the RealTek r1000 driver?
> >>FWIW, RealTek emailed me about merging r1000.  I suggested that, if the 
> >
> >Which one ?
> >
> >r1000_n.c where #define RELEASE_DATE "2006/02/23"
> 
> They didn't say.  Just "r1000"

Can you ask your Realtek person if he is really sure about the following
snippet in r1000_n.c::r1000_init_one:

		if((priv->mcfg!=MCFG_METHOD_13)&&(priv->mcfg!=MCFG_METHOD_14)&&(priv->mcfg!=MCFG_METHOD_15))
			printk("This Realtek NIC doesn't support 1000Mbps\n");
		else
			Cap1000 = PHY_Cap_1000_Full|PHY_Cap_1000_Half;

-> in forced 1000 mode, 1000_{Half/Full} would only be written to the
   advertisement register for MCFG_METHOD_1{3/4/5}. It excludes all
   the adapters that the in-kernel driver support (huh ?).

Later in the same function:
[...]
	if(( priv->mcfg == MCFG_METHOD_11 )||( priv->mcfg == MCFG_METHOD_12 ))
		printk("Realtek RTL8168/8111 Family PCI-E Gigabit Ethernet Network Adapter\n");
	else if((priv->mcfg==MCFG_METHOD_13)||(priv->mcfg==MCFG_METHOD_14)||(priv->mcfg==MCFG_METHOD_15))
		printk("Realtek RTL8139/810x Family Fast Ethernet Network Adapter\n");

-> the != ... && ... != test above seems inverted.

Btw, it would be nice if he could confirm that the 0x10ec/0x8129 ID
sent by Yoichi Yuasa is really allowed (and not a random bitflip).

-- 
Ueimor
