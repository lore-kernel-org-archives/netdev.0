From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/fec: carrier off initially to avoid root mount
 failure
Date: Fri, 08 Oct 2010 13:50:21 -0700 (PDT)
Message-ID: <20101008.135021.242120920.davem@davemloft.net>
References: <1286454630-7396-1-git-send-email-oskar@linutronix.de>
	<20101008.103112.189689736.davem@davemloft.net>
	<20101008203530.GA11926@www.tglx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan@embeddedalley.com,
	bigeasy@linutronix.de, hjk@linutronix.de, gerg@uclinux.org
To: oskar@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60656
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759627Ab0JHUuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 16:50:00 -0400
In-Reply-To: <20101008203530.GA11926@www.tglx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oskar Schirmer <oskar@linutronix.de>
Date: Fri, 8 Oct 2010 22:35:30 +0200

> So when asking for the most correct place to fix this, I'ld propose
> phylib itself: Shouldn't the correct carrier state be set with
> phy_start_machine or phy_device_create when phy state is set to
> PHY_DOWN?

I agree, phylib is the best place to handle this.

The carrier defaults to "on" for newly created net devices
since that's what software devices and hardware ones which
lack a link want.

phy_device_create() currently lacks access to the network device
struct.

phy_connect_direct() and phy_attach_direct() might be good spots.

