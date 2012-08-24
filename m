From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/15] qlcnic: patches for new adapter - Qlogic
 83XX CNA
Date: Fri, 24 Aug 2012 12:56:56 -0400 (EDT)
Message-ID: <20120824.125656.2080260426772048132.davem@davemloft.net>
References: <1345770439-30517-1-git-send-email-sony.chacko@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: sony.chacko@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54283 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753539Ab2HXQ5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 12:57:00 -0400
In-Reply-To: <1345770439-30517-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>
Date: Thu, 23 Aug 2012 21:07:04 -0400

> From: Sony Chacko <sony.chacko@qlogic.com>
> 
> Patch series will restructure the existing 82XX adapter driver to create
> a common driver for Qlogic 82XX and 83XX adapters.
> 
> Please apply it to net-next.

Sorry, this is terrible.

Firstly, I'm not going to let you create arbitrary new sysfs and
debugfs crap for facilities that are already supported by the kernel
via other interfaces.

For example, providing a facility to read and write the PCI BARs
is completely pointless.  Use the PCI config space access APIs for
this if you want to do this from userspace.

The patches are also much more verbose than they need to be.  When you
move an operation to the new hwops, keep the existing function name
but make it an inline function that invokes the hwop.

That way you won't need hundreds of lines in your patch that look
like this:


-	qlcnic_clear_lb_mode(adapter);
+	ahw->hw_ops->clear_loopback(adapter, mode);

Instead you'd have:

static inline void qlcnic_clear_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
{
	struct qlcnic_hardware_context *ahw = &adapter->ahw;

	ahw->hw_ops->clear_loopback(adapter, mode);
}
