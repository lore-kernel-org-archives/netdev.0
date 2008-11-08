From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: Guaranetee the proper ordering of the
 loopback device. v2
Date: Fri, 07 Nov 2008 22:55:29 -0800 (PST)
Message-ID: <20081107.225529.45534653.davem@davemloft.net>
References: <m14p2l0zyu.fsf@frodo.ebiederm.org>
	<m1y6zwzx4r.fsf_-_@frodo.ebiederm.org>
	<m1skq4zx26.fsf_-_@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlezcano@fr.ibm.com, containers@lists.osdl.org, den@openvz.org,
	xemul@openvz.org, netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57318
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752300AbYKHGz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Nov 2008 01:55:29 -0500
In-Reply-To: <m1skq4zx26.fsf_-_@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 06 Nov 2008 07:36:00 -0800

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
> But do it carefully so we register the loopback device after
> we clear dev_boot_phase.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@maxwell.aristanetworks.com>

Applied.
