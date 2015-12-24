From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH v2] r8152: fix lockup when runtime PM is enabled
Date: Thu, 24 Dec 2015 08:14:40 +0100
Message-ID: <1450941280.28243.8.camel@suse.com>
References: <Pine.LNX.4.44L0.1512232026510.19895-100000@netrider.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hayes Wang <hayeswang@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"peter@lekensteyn.nl" <peter@lekensteyn.nl>
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:59630 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754500AbbLXHQt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Dec 2015 02:16:49 -0500
In-Reply-To: <Pine.LNX.4.44L0.1512232026510.19895-100000@netrider.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-12-23 at 20:32 -0500, Alan Stern wrote:

> I don't understand why the wakeup conditions are different.  It seems
> to me that the choice of which packets will generate a wakeup ought to
> depend on the user's selection, not on the kind of suspend.  For
> instance, if the user says that only a magic packet should cause a
> wakeup then that should be true for both runtime suspend and system
> suspend.
> 
> To put it another way, as far as the device is concerned a suspend is
> just a suspend -- there's no different between a runtime suspend and a
> system suspend.

This literally true, but the host and the driver care.
If we autosuspend a running network device, any packet
(maybe filtered for MAC) should cause a remote wake up,
else we'd lose packets.

But you cannot keep that setting if the system goes down
or any broadcast packet would resume the whole system.
Yet you cannot just disable remote wake up, as WoL packages
still must trigger a remote wake up.
So there are drivers which must change settings on devices
as the system goes to sleep, even if their devices have
already been autosuspended. We could use the notifier chains
for that. But can this solution be called elegant?

	Merry Christmas
		Oliver
