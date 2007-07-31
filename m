From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC]: napi_struct V4
Date: Mon, 30 Jul 2007 19:03:50 -0700 (PDT)
Message-ID: <20070730.190350.52168394.davem@davemloft.net>
References: <ada7ioiszk7.fsf@cisco.com>
	<20070730.154854.07455239.davem@davemloft.net>
	<adamyxdpbzg.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com, hadi@cyberus.ca, rusty@rustcorp.com.au
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54635
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758241AbXGaCDu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 22:03:50 -0400
In-Reply-To: <adamyxdpbzg.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Mon, 30 Jul 2007 19:01:55 -0700

> Are you saying that netif_rx_reschedule() itself is racy?

Nevermind, you're right.

I'll see if I can resurrect something akin to netif_rx_reschedule()
when I get back to the NAPI patches.  Probably what I'll do is let
the ->poll() handler make sure to accumulate 'rx' work counts if
it loops again on netif_rx_reschedule() instead of dorking with
the quota and budget in that helper function.

