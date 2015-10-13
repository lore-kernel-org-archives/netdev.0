From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] be2net: patch set
Date: Tue, 13 Oct 2015 04:33:09 -0700 (PDT)
Message-ID: <20151013.043309.127713881104628783.davem@davemloft.net>
References: <1444636041-4727-1-git-send-email-sathya.perla@avagotech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@avagotech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47418 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752060AbbJMLRI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 07:17:08 -0400
In-Reply-To: <1444636041-4727-1-git-send-email-sathya.perla@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@avagotech.com>
Date: Mon, 12 Oct 2015 03:47:16 -0400

> Patch 1 fixes a FW image compatibility check in the driver that
> prevents certain FW images from being flashed on BE3 (not BE3-R)
> adapters.
> 
> Patch 2 fixes a spin_lock not being released in a failure case in
> be_cmd_notify_wait().
> 
> Patch 3 includes a workaround to pad packets that are only 32b long or less
> to be applicabe to BE3 too. This workaround was currently applied only to
> Skyhawk and Lancer chips. Such packets are causing BE3's TX path to stall
> on a SR-IOV config.
> 
> Patch 4 fixes the be_cmd_get_profile_config() routine to set the pf_num
> field in the cmd request. The FW requires this field to be set for it to
> return the specific function's descriptors. If not set, the FW returns
> the descriptors of all the functions on the device. If the first descriptor
> is not what is being queried for, the driver will read wrong data.
> This patch fixes this issue by using the GET_CNTL_ATTRIB cmd to query the
> real pci_func_num of a function and then uses it in the GET_PROFILE_CONFIG
> cmd.
> 
> Patch 5 completes an earlier fix that removed the vlan promisc capability
> for VFs. The earlier fix did not update the removal of this capability from
> the profile descriptor of the VF. This causes the VF driver to request this
> capability when it tries to create it's interface at probe time. This could
> potentailly cause the VF probe to fail if the FW enforces strict checking of
> the flags based on what was provisoned by the PF.  This strict checking is
> not being done by FW currently but will be fixed in a future version. This
> patch fixes this issue by updating the VF's profile descriptor so that they
> match the interface capability flags provisioned by the PF.
> 
> Pls consider adding these patches to the net tree. Thanks!

Series applied, thanks.
