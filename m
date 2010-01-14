From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/2] ixgbe: Do not attempt to perform
 interrupts in netpoll when down
Date: Wed, 13 Jan 2010 17:15:28 -0800 (PST)
Message-ID: <20100113.171528.05861304.davem@davemloft.net>
References: <20100113114847.23119.36954.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com, mallikarjuna.chilakala@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58579
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751411Ab0ANBPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 20:15:19 -0500
In-Reply-To: <20100113114847.23119.36954.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 13 Jan 2010 03:49:13 -0800

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This patch resolves issues seen when running netconsole and rebooting via
> reboot -f.  The issue was due to the fact that we were attempting to
> perform interrupt actions when the q_vectors and rings had already been
> freed via the ixgbe_shutdown routines.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Acked-by:  Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

There has to be a better way to handle this, though.  In fact
I would expect the device to be detached early enough (and
thus ->netpoll() calls prevented) long before you would be
freeing up resources and shutting down the chip.

Why doesn't that happen?
