From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 2/4] r8169: explicit firmware format check.
Date: Sat, 18 Jun 2011 00:11:14 +0200
Message-ID: <20110617221114.GA2441@electric-eye.fr.zoreil.com>
References: <20110617192826.GA2277@electric-eye.fr.zoreil.com> <20110617193105.GB2287@electric-eye.fr.zoreil.com> <1308345200.2831.31.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>,
	Ben Hutchings <ben@decadent.org.uk>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:58525 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758681Ab1FQWYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 18:24:03 -0400
Content-Disposition: inline
In-Reply-To: <1308345200.2831.31.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <bhutchings@solarflare.com> :
[...]
> > @@ -1230,7 +1239,7 @@ static void rtl8169_get_drvinfo(struct net_device *dev,
> >  	strcpy(info->version, RTL8169_VERSION);
> >  	strcpy(info->bus_info, pci_name(tp->pci_dev));
> >  	strncpy(info->fw_version, IS_ERR_OR_NULL(rtl_fw) ? "N/A" :
> > -		rtl_lookup_firmware_name(tp), sizeof(info->fw_version) - 1);
> > +		rtl_fw->version, RTL_VER_SIZE);
> 
> You appear to ensure that rtl_fw->version is properly terminated, so I
> would suggest:
> 
> 	BUILD_BUG_ON(sizeof(info->fw_version) < sizeof(rtl_fw->version));
> 	strcpy(info->fw_version, IS_ERR_OR_NULL(rtl_fw) ? "N/A" : rtl_fw->version);

Ok.

[...]
> > +	if (!(fw->size % FW_OPCODE_SIZE)) {
> > +		snprintf(rtl_fw->version, RTL_VER_SIZE, "%s",
> > +			 rtl_lookup_firmware_name(tp));
> 
> strlcpy()

Ok.

[...]
> This function is doing rather more than what its name suggests.  And it
> always returns true, so it doesn't actually do what its name suggests at
> all.

No idea for a short better name. Will fix the return part.

-- 
Ueimor
