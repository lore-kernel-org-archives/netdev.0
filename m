From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [net-next:master 664/670]
 drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c:1421:7-9: WARNING: possible
 condition with no effect (if == else)
Date: Mon, 14 Nov 2016 08:49:22 -0600
Message-ID: <9b026acd-7bfc-cc6e-5f11-acb6b94a2347@amd.com>
References: <alpine.DEB.2.20.1611131910380.1946@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <kbuild-all@01.org>
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0065.outbound.protection.outlook.com ([104.47.32.65]:20288
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751662AbcKNOtm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Nov 2016 09:49:42 -0500
In-Reply-To: <alpine.DEB.2.20.1611131910380.1946@hadrien>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/13/2016 12:12 PM, Julia Lawall wrote:
> It looks like the code on lines 1422 and 1424 is the same, so either the
> test may be unnecessary, or one of the branches is wrong.

I was trying to show that for a cable length of less than 5 meters I was
using a specific sub-command and that for anything longer I was falling
back to the 5 meter value.  I can see how it doesn't look right and I'll
clean it up with a patch.

> 
> Coccinelle is also comparing about a comparison on an unsigned value in
> line 1900, but the code for that is not listed in the report below.

Ok, good catch.  I'll fix this up with a patch also.

Thanks,
Tom

> 
> julia
> 
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> head:   f7ad3d4b83e694347cddc96d956143068bef32c9
> commit: abf0a1c2b26ad964d19b143ce46735e1b0667f29 [664/670] amd-xgbe: Add support for SFP+ modules
> :::::: branch date: 16 minutes ago
> :::::: commit date: 12 hours ago
> 
>>> drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c:1421:7-9: WARNING: possible condition with no effect (if == else)
> --
>>> drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c:1900:6-9: WARNING: Unsigned expression compared with zero: ret < 0
> 
> git remote add net-next https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git
> git remote update net-next
> git checkout abf0a1c2b26ad964d19b143ce46735e1b0667f29
> vim +1421 drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c
> 
> abf0a1c2 Lendacky, Thomas 2016-11-10  1405  {
> abf0a1c2 Lendacky, Thomas 2016-11-10  1406  	struct xgbe_phy_data *phy_data = pdata->phy_data;
> abf0a1c2 Lendacky, Thomas 2016-11-10  1407  	unsigned int s0;
> abf0a1c2 Lendacky, Thomas 2016-11-10  1408
> abf0a1c2 Lendacky, Thomas 2016-11-10  1409  	xgbe_phy_start_ratechange(pdata);
> abf0a1c2 Lendacky, Thomas 2016-11-10  1410
> abf0a1c2 Lendacky, Thomas 2016-11-10  1411  	/* 10G/SFI */
> abf0a1c2 Lendacky, Thomas 2016-11-10  1412  	s0 = 0;
> abf0a1c2 Lendacky, Thomas 2016-11-10  1413  	XP_SET_BITS(s0, XP_DRIVER_SCRATCH_0, COMMAND, 3);
> abf0a1c2 Lendacky, Thomas 2016-11-10  1414  	if (phy_data->sfp_cable != XGBE_SFP_CABLE_PASSIVE) {
> abf0a1c2 Lendacky, Thomas 2016-11-10  1415  		XP_SET_BITS(s0, XP_DRIVER_SCRATCH_0, SUB_COMMAND, 0);
> abf0a1c2 Lendacky, Thomas 2016-11-10  1416  	} else {
> abf0a1c2 Lendacky, Thomas 2016-11-10  1417  		if (phy_data->sfp_cable_len <= 1)
> abf0a1c2 Lendacky, Thomas 2016-11-10  1418  			XP_SET_BITS(s0, XP_DRIVER_SCRATCH_0, SUB_COMMAND, 1);
> abf0a1c2 Lendacky, Thomas 2016-11-10  1419  		else if (phy_data->sfp_cable_len <= 3)
> abf0a1c2 Lendacky, Thomas 2016-11-10  1420  			XP_SET_BITS(s0, XP_DRIVER_SCRATCH_0, SUB_COMMAND, 2);
> abf0a1c2 Lendacky, Thomas 2016-11-10 @1421  		else if (phy_data->sfp_cable_len <= 5)
> abf0a1c2 Lendacky, Thomas 2016-11-10  1422  			XP_SET_BITS(s0, XP_DRIVER_SCRATCH_0, SUB_COMMAND, 3);
> abf0a1c2 Lendacky, Thomas 2016-11-10  1423  		else
> abf0a1c2 Lendacky, Thomas 2016-11-10  1424  			XP_SET_BITS(s0, XP_DRIVER_SCRATCH_0, SUB_COMMAND, 3);
> abf0a1c2 Lendacky, Thomas 2016-11-10  1425  	}
> abf0a1c2 Lendacky, Thomas 2016-11-10  1426
> abf0a1c2 Lendacky, Thomas 2016-11-10  1427  	/* Call FW to make the change */
> abf0a1c2 Lendacky, Thomas 2016-11-10  1428  	XP_IOWRITE(pdata, XP_DRIVER_SCRATCH_0, s0);
> abf0a1c2 Lendacky, Thomas 2016-11-10  1429  	XP_IOWRITE(pdata, XP_DRIVER_SCRATCH_1, 0);
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
> 
