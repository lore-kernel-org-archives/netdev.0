From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip_tunnel: fix ip_tunnel_lookup
Date: Tue, 08 Jul 2014 19:35:36 -0700 (PDT)
Message-ID: <20140708.193536.1470966008910828465.davem@davemloft.net>
References: <20140705022637.73152ff57309c468c1fdb563@qrator.net>
	<20140708.151210.1879376103263511218.davem@davemloft.net>
	<20140709044759.009fdce94cf1fb2d872a4a4f@qrator.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ixaphire@qrator.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55927 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751163AbaGICfh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 22:35:37 -0400
In-Reply-To: <20140709044759.009fdce94cf1fb2d872a4a4f@qrator.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Popov <ixaphire@qrator.net>
Date: Wed, 9 Jul 2014 04:47:59 +0400

> How I see ip_tunnel_lookup logic:
> 1) try to find exact match (and if found return this tunnel):
> tunnel.saddr == iph.daddr && tunnel.daddr == iph.saddr && key_matched()
> 2) try to find matched (local) wildcard tunnel:
> tunnel.saddr == any && tunnel.daddr == iph.saddr && key_matched()
> 3) try to find matched (remote) wildcard tunnel:
> tunnel.saddr == iph.daddr && tunnel.daddr == any && key_matched()
> (there is also a test for multicast tunnel, but let's skip it for simplicity)
> 4) try to find matched (full) wildcard tunnel:
> tunnel.saddr == any && tunnel.daddr == any && key_matched()
> 5) if nothing found return default tunnel.
> 
> According to this logic, in 4th loop (the one you quoted) we have to test that
> tunnel.daddr == any && tunnel.saddr == any. In my opinion those two new lines
> are the best way to achieve it.

Now it makes sense, thanks for explaining.

Applied and queued up for -stable, thanks again.
