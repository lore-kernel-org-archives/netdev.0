From: Mike McCormack <mikem@ring3k.org>
Subject: Re: [PATCH] sky2: Fix a race condition in sky2_poll
Date: Tue, 7 Jul 2009 13:09:30 +0900
Message-ID: <392fb48f0907062109t207d4c3evfa25281029544ef@mail.gmail.com>
References: <392fb48f0906200101y5c83e853w170829f2ce40b274@mail.gmail.com>
	 <20090706115101.68a8daaf@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f226.google.com ([209.85.217.226]:51683 "EHLO
	mail-gx0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750817AbZGGEJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2009 00:09:27 -0400
Received: by gxk26 with SMTP id 26so1558160gxk.13
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2009 21:09:30 -0700 (PDT)
In-Reply-To: <20090706115101.68a8daaf@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

2009/7/7 Stephen Hemminger <shemminger@linux-foundation.org>:

> Have you actually seen this race, or are you hypothesizing based
> on code review?

Based on code review prompted by seeing "receiver hang detected"
messages in the log.

> I think the original works fine. There is a race where interrupt is cleared early,
> and the poll processing runs an extra time but that is harmless.

There also appears to be a logic problem where the interrupt will not
be cleared until another packet is received, which is the case I was
originally trying to fix.  It looks like if just enough packets are
received (so work_done >= to_do and we go through exit_loop) in
sky2_status_intr(), the interrupt may not be cleared even though no
packets remain.

> Now the driver misses the status interrupt.

My interpretation was that the interrupt condition must be cleared at
least once before acknowledging it.

In any case, the receiver hang detection logic will restart the
driver.  I see this happening quite a bit, and it seems to happen most
commonly after sky2_up is called.

thanks,

Mike
