From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb4vf: fix crash due to manipulating queues before
 registration
Date: Fri, 29 Oct 2010 13:05:59 -0700 (PDT)
Message-ID: <20101029.130559.112585228.davem@davemloft.net>
References: <1288297007-663-1-git-send-email-leedom@chelsio.com>
	<20101028.132122.245402585.davem@davemloft.net>
	<8A71B368A89016469F72CD08050AD334088DA49E@maui.asicdesigners.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leedom@chelsio.com, netdev@vger.kernel.org
To: dm@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59723
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751393Ab0J2UFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 16:05:35 -0400
In-Reply-To: <8A71B368A89016469F72CD08050AD334088DA49E@maui.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dimitrios Michailidis" <dm@chelsio.com>
Date: Fri, 29 Oct 2010 00:36:22 -0700

> Further, I believe moving the call after register_netdev is buggy as
> open can be called after registration and it can clash with the
> queue stopping.  It seems then that these netif_tx_stop_all_queues
> calls have to go now.

This is a good explanation of why no driver should be touching the
queue state before the first ->open() call.
