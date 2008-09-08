From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] niu: panic on reset
Date: Mon, 08 Sep 2008 13:20:31 -0700 (PDT)
Message-ID: <20080908.132031.65821182.davem@davemloft.net>
References: <48C07564.3060306@Sun.COM>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Matheos.Worku@Sun.COM, agospoda@redhat.com
To: Santwona.Behera@Sun.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57704
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752899AbYIHUUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 16:20:38 -0400
In-Reply-To: <48C07564.3060306@Sun.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Santwona.Behera@Sun.COM
Date: Thu, 04 Sep 2008 16:55:16 -0700

[ Please learn how to hit the return key every 80 characters or so,
  long lines are very difficult to read on text-only email clients
  like the one I use.  Expecting auto-formatting and other beautifications
  in email readers amongst kernel developers is a very bad idea. ]

> The reset_task function in the niu driver does not reset the
> hardware fully. The buffer addresses and pointers are not being
> reset/updated in the hardware and that leads to panic on reset.
>
> Signed-off-by: santwona.behera@sun.com <santwona.behera@sun.com>

This is way overkill just to fix this bug and it adds a new failure
mode for the driver which is a seriously negative aspect to this fix.

Instead, simply write a function which reloads the buffers addresses
properly instead of calling the functions to free and reallocate all
of these dynamic datastructures just to get those side effects.
