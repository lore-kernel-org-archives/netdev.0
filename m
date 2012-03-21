From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: locking in net_device_ops callbacks
Date: Thu, 22 Mar 2012 00:37:20 +0100
Message-ID: <20120321233720.GA14134@electric-eye.fr.zoreil.com>
References: <471DE477E2B1F549A58F3A14A27180BE014357@HQ-EX01.bytemobile.com> <20120321122503.25838566@nehalam.linuxnetplumber.net> <471DE477E2B1F549A58F3A14A27180BE0147A6@HQ-EX01.bytemobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jeff Haran <jharan@bytemobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:38691 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751679Ab2CUXj1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2012 19:39:27 -0400
Content-Disposition: inline
In-Reply-To: <471DE477E2B1F549A58F3A14A27180BE0147A6@HQ-EX01.bytemobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Haran <jharan@bytemobile.com> :
[...]
> It seems to me that some other serialization mechanism should be in place
> to serialize soft IRQ context access to instances of struct net_device.

The driver must implement adequate locking -mostly bh or irq spinlock- if
you want to change the MTU at any time. It is possible to temporarily stop
some bh as well too, see napi_disable for instance.

net_device stats locking is a different beast.

Other than that, some serializing is already done with rules such as
"xmit happens in locally bh disabled context" or through special purpose
lock (think Tx locking).

So, yes, there are some mechanisms. However most drivers only care about
the net_device itself when it goes up or down. As soon as the net_device
is up, it won't change much behind the driver's back (nor should the driver
try to modify it much btw).

-- 
Ueimor
