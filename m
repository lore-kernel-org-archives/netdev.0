From: David Miller <davem@davemloft.net>
Subject: Re: qdisc and down links (regression)
Date: Thu, 07 Aug 2008 15:47:35 -0700 (PDT)
Message-ID: <20080807.154735.148985698.davem@davemloft.net>
References: <20080807143036.1ae10482@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vgr.kernel.org
To: stephen.hemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58848
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752322AbYHGWrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 18:47:35 -0400
In-Reply-To: <20080807143036.1ae10482@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Date: Thu, 7 Aug 2008 14:30:36 -0700

> Before the mulitqueue changes in 2.6.27-rc it was possible to setup
> queueing disciplines before the link came up (carrier active). This
> no longer works. If link is down, the qdisc is the noop_qdisc and
> any configuration changes don't seem to be shown.

I'll see why this happens, it wasn't an intentional change.

Before the link comes up, we don't activate the qdisc.  We just
remember it in ->qdisc_sleeping.  I bet if you bring the link up the
configuration will become visible, or that is the area where the
unintentional error is occuring.
