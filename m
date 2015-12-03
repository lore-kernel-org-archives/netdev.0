From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] openvswitch: fix hangup on vxlan/gre/geneve device
 deletion
Date: Thu, 03 Dec 2015 14:30:48 -0500 (EST)
Message-ID: <20151203.143048.662288701351689156.davem@davemloft.net>
References: <d3c53f79dfaacd71bebf97427388d60dc5652eae.1448989843.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com, tgraf@suug.ch,
	dev@openvswitch.org, fbl@sysclose.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43852 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751618AbbLCTau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 14:30:50 -0500
In-Reply-To: <d3c53f79dfaacd71bebf97427388d60dc5652eae.1448989843.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Tue,  1 Dec 2015 18:33:36 +0100

> Each openvswitch tunnel vport (vxlan,gre,geneve) holds a reference
> to the underlying tunnel device, but never released it when such
> device is deleted.
> Deleting the underlying device via the ip tool cause the kernel to
> hangup in the netdev_wait_allrefs() loop.
> This commit ensure that on device unregistration dp_detach_port_notify()
> is called for all vports that hold the device reference, properly
> releasing it.
> 
> Fixes: 614732eaa12d ("openvswitch: Use regular VXLAN net_device device")
> Fixes: b2acd1dc3949 ("openvswitch: Use regular GRE net_device instead of vport")
> Fixes: 6b001e682e90 ("openvswitch: Use Geneve device.")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied and queued up for -stable, thank you.
