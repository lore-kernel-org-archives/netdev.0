From: David Miller <davem@davemloft.net>
Subject: Re: tg3 appears to be sick in 2.6.33
Date: Sun, 10 Jan 2010 13:52:42 -0800 (PST)
Message-ID: <20100110.135242.113292015.davem@davemloft.net>
References: <20100108180915.GA8218@xw6200.broadcom.net>
	<201001081025.50298.dmitry.torokhov@gmail.com>
	<20100108194222.GA8386@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dmitry.torokhov@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, jfeeney@redhat.com
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50691
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753958Ab0AJVwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2010 16:52:33 -0500
In-Reply-To: <20100108194222.GA8386@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Fri, 8 Jan 2010 11:42:22 -0800

> [PATCH] tg3: Fix std rx prod ring handling
> 
> There are some tg3 devices that require the driver to post new rx
> buffers in smaller increments.  Commit
> 4361935afe3abc3e5a93006b99197fac1fabbd50, "tg3: Consider
> rx_std_prod_idx a hw mailbox" changed how the driver tracks the rx
> producer ring updates, but it does not make any special considerations
> for the above-mentioned devices.  For those devices, it is possible for
> the driver to hit the special case path, which updates the hardware
> mailbox register but skips updating the shadow software mailbox member.
> If the special case path represents the final mailbox update for this
> ISR iteration, the hardware and software mailbox values will be out of
> sync.  Ultimately, this will cause the driver to use a stale mailbox
> value on the next iteration, which will appear to the hardware as a
> large rx buffer update.  Bad things ensue.
> 
> The fix is to update the software shadow mailbox member when the special
> case path is taken.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>

Matt, since we have positive testing, want me to apply this?

Thanks.
