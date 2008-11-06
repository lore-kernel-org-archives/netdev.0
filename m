From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net: Guaranetee the proper ordering of the
 loopback device.
Date: Wed, 05 Nov 2008 16:00:47 -0800 (PST)
Message-ID: <20081105.160047.174722021.davem@davemloft.net>
References: <48ECA8D2.4090406@openvz.org>
	<m14p2l4v2l.fsf_-_@frodo.ebiederm.org>
	<m1y6zx3gcs.fsf_-_@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlezcano@fr.ibm.com, containers@lists.osdl.org, den@openvz.org,
	xemul@openvz.org, netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36982
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752649AbYKFABM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 19:01:12 -0500
In-Reply-To: <m1y6zx3gcs.fsf_-_@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 05 Nov 2008 15:25:39 -0800

> 
> I was recently hunting a bug that occurred in network namespace
> cleanup.  In looking at the code it became apparrent that we have
> and will continue to have cases where if we have anything going
> on in a network namespace there will be assumptions that the
> loopback device is present.   Things like sending igmp unsubscribe
> messages when we bring down network devices invokes the routing
> code which assumes that at least the loopback driver is present.
> 
> Therefore to avoid magic initcall ordering hackery that is hard
> to follow and hard to get right insert a call to register the
> loopback device directly from net_dev_init().    This guarantes
> that the loopback device is the first device registered and
> the last network device to go away.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied.
