From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] bridge: kernel panic when unloading bridge module
Date: Tue, 29 Apr 2008 03:18:23 -0700 (PDT)
Message-ID: <20080429.031823.214117840.davem@davemloft.net>
References: <20080428172809.7f814ed5@extreme>
	<20080428172907.2517c12e@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bstroesser@fujitsu-siemens.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59033
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752479AbYD2KSZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 06:18:25 -0400
In-Reply-To: <20080428172907.2517c12e@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 28 Apr 2008 17:29:07 -0700

> There is a race condition when unloading bridge and netfilter.
> 
> The problem happens if __fake_rtable is in use by a skb
> coming in, while someone starts to unload bridge.ko.
> br_netfilter_fini() is called at the beginning of unload
> in br_deinit() while skbs still are being forwarded and
> transferred to local ip stack. Thus there is a possibility
> of the __fake_rtable pointer not being removed in a skb that
> goes up to ip stack. This results in a kernel panic, as
> ip_rcv() calls the input-function of __fake_rtable, which
> is NULL.
> 
> Moving the call of br_netfilter_fini() to the end of
> br_deinit() solves the problem.
> 
> Signed-off-by: Bodo Stroesser <bstroesser@fujitsu-siemens.com>
> Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>

Also applied, thanks.
