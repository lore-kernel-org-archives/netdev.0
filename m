From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 3/7] [PATCH 3/8] can: CAN Network device driver and
 Netlink interface
Date: Wed, 13 May 2009 08:57:34 -0700
Message-ID: <20090513085734.387dddbe.akpm@linux-foundation.org>
References: <20090512092757.048938233@denx.de>
	<20090512092757.574693100@denx.de>
	<20090512233052.ecd600f1.akpm@linux-foundation.org>
	<20090512235323.e3de5e5d.akpm@linux-foundation.org>
	<4A0AB0EC.5010902@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43013 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754879AbZEMQAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 12:00:05 -0400
In-Reply-To: <4A0AB0EC.5010902@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 May 2009 13:37:16 +0200 Wolfgang Grandegger <wg@grandegger.com> wrote:

> > Also, I wonder if it's safe to take netif_tx_lock() from a timer
> > handler when other parts of the code might be taking it from process
> > context (I didn't check).
> > 
> > lockdep should be able to detect this, and I trust this code has been
> > fully runtime tested with lockdep enabled?
> 
> Well, CONFIG_PROVE_LOCKING would be cool, but I'm unable to enabled it
> for my MPC5200 test system. Only 64bit PowerPC's seem to support
> TRACE_IRQFLAGS_SUPPORT. I'm going to test the code on a PC as well.

I discussed this off-list with Peter Zijlstra and Johannes Berg. 
Apparently lockdep _will_ detect this deadlockable situation - Johannes
recently added the capability because he had the same situation in
wireless code somewhere.

But of course it does require that the timer handler has executed at
least once.  Many handlers in the kernel never fire in normal operation.

