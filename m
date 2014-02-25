From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/5] gianfar: Device reset and reconfig
 fixes
Date: Mon, 24 Feb 2014 19:39:12 -0500 (EST)
Message-ID: <20140224.193912.2219449920663424370.davem@davemloft.net>
References: <1393236826-13059-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben@decadent.org.uk
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48755 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751539AbaBYAjO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 19:39:14 -0500
In-Reply-To: <1393236826-13059-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Mon, 24 Feb 2014 12:13:41 +0200

> These patches end up fixing some notable device reset & reconfig
> related problems.  One issue is on-the-fly (Rx/Tx on) programming
> of interrupt coalescing (IC) registers on the processing path,
> against HW recommendation.  This is an old issue that became visible
> after BQL introduction, as under certain conditions (low traffic)
> one TX interrupt gets lost and BQL fires Tx timeout as a result.
> Another notable issue is a race on the Tx path (xmit, clean_tx)
> during device reset (i.e. during Tx timeout watchdog firing)
> that leads to NULL access.
> Fixing the problematic on-thy-fly register writes (i.e. the IC regs)
> required the implementation of a MAC soft reset procedure.
> The race leading to NULL access was addressed by fixing the
> stop_gfar()/startup_gfar() pair (disable/enable napi a.s.o.)
> and adding the device state DOWN to sync with the TX path.
> 
> Thanks.
> --
> v2: Refactored if() clauses from gfar_set_features(), PATCH 2.

Series applied, thanks Claudiu.
