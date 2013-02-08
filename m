From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: fix phy_device_free memory leak
Date: Thu, 07 Feb 2013 23:35:47 -0500 (EST)
Message-ID: <20130207.233547.1110391470421534770.davem@davemloft.net>
References: <201302070007.57434.oss@malat.biz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: oss@malat.biz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56680 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757902Ab3BHEft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 23:35:49 -0500
In-Reply-To: <201302070007.57434.oss@malat.biz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Malat <oss@malat.biz>
Date: Thu, 7 Feb 2013 00:07:57 +0100

> Hi,
> there is a memory leak in phy_device handling:
> phy_device_create() sets name of kobject using dev_set_name(), which allocates 
> memory using kvasprintf(), but this memory isn't freed if the underlying 
> device isn't registered properly, because kobject_cleanup() is not called in 
> that case. This can happen (and actually is happening on our machines) if 
> phy_device_register(), called by mdiobus_scan(), fails. I fixed this by the 
> attached patch, so far it's working fine.
> 
> Patch description:
> Name is freed by phy_device_free(). In the case a device is released trough 
> kobject_cleanup()->device_release()->phy_device_release(), the name is set to 
> NULL and it is not freed by phy_device_free(), because it will be freed later 
> by kobject_cleanup().
> 
> Please put me on CC, I'm not signed into the mailing list.

Please follow the directions in Documentation/SubmittingPatches, in
particular the part about providing a proper signoff.

Do not send an updated version of this patch as a reply to this thread,
instead create a completely new mailing list posting for that purpose.

Thanks.
