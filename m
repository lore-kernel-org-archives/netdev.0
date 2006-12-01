From: Ulrich Kunitz <kune@deine-taler.de>
Subject: Re: [PATCH] zd1211rw: Support for multicast addresses
Date: Fri, 1 Dec 2006 07:27:59 +0100
Message-ID: <20061201062758.GA20548@p15091797.pureserver.info>
References: <20061201005807.C04067B409F@zog.reactivated.net> <20061130175036.35f0ccf7@localhost.localdomain> <456F8BF6.7020304@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, linville@tuxdriver.com,
	netdev@vger.kernel.org, benoit.papillault@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:47565 "EHLO
	p15091797.pureserver.info") by vger.kernel.org with ESMTP
	id S1759151AbWLAG2A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Dec 2006 01:28:00 -0500
To: Daniel Drake <dsd@gentoo.org>
Content-Disposition: inline
In-Reply-To: <456F8BF6.7020304@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06-11-30 20:57 Daniel Drake wrote:

> Stephen Hemminger wrote:
> >Why all the trouble do it off work queue? Is someone calling
> >set_multicast_list with IRQ's disabled?
> 
> Register I/O involves sleeping, so we need to be in process context.
> 
> in_atomic() returns non-zero in the set_multicast_list handler. I 
> couldn't tell you which codepath this is in.
> 
> Daniel

The function dev_mc_upload() (net/core/dev_mcast.c) calls
netif_tx_lock_bh() which locks the tx spinlock.

The ZD1211 is a USB chip. Register reads will always require
sleeping, if the driver should not spend CPU cycles on polling in
atomic mode. One could implement register writes without waiting
for completion of the writes, but asynchronous error messages for
the writes would make debugging difficult. Additionally hardware
register accesses includes setting a firmware lock, which reqires
a register read. Given all that the driver is always sleeping in
the register access paths. RX and TX paths don't require register
access and work in atomic mode. 

-- 
Uli Kunitz
