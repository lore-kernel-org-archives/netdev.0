From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] Long term PMTU/redirect storage in ipv4.
Date: Tue, 17 Jul 2012 15:09:20 -0700 (PDT)
Message-ID: <20120717.150920.1324071045620152376.davem@davemloft.net>
References: <alpine.LFD.2.00.1207172249270.1831@ja.ssi.bg>
	<20120717.134651.562831385960975623.davem@davemloft.net>
	<alpine.LFD.2.00.1207180052420.2128@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55403 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962Ab2GQWJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 18:09:21 -0400
In-Reply-To: <alpine.LFD.2.00.1207180052420.2128@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Wed, 18 Jul 2012 01:14:04 +0300 (EEST)

> 	Aha, I see. Something around fnhe_oldest() and its
> daddr arg does not look good. If the goal is to hijack
> some entry, probably for another daddr and comparing it with
> tcpm_new(), may be we should remove this daddr arg and fully
> reset all parameters such as fnhe_pmtu, fnhe_gw, fnhe_expires
> because the find_or_create_fnhe() callers modify only specific
> fields, we should not end up with wrong gateway inherited from
> another daddr, for example.

Better would be to use a seqlock when reading it's values.

Either way, patches welcome :-)
