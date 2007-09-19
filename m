From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Preliminary release of Sun Neptune driver
Date: Wed, 19 Sep 2007 16:17:17 -0700 (PDT)
Message-ID: <20070919.161717.57157258.davem@davemloft.net>
References: <20070919145900.759ef19e@freepuppy.rosehill.hemminger.net>
	<20070919.150755.38714639.davem@davemloft.net>
	<20070919160520.709a6819@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Hendel@sun.com, greg.onufer@sun.com,
	jeff@garzik.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36840
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755577AbXISXRR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 19:17:17 -0400
In-Reply-To: <20070919160520.709a6819@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 19 Sep 2007 16:05:20 -0700

> GCC is not as smart as you think... Try the following test:

Indeed, thanks for pointing that out.  I'll have to
macroize it like this to get the check:

static int __niu_wait_bits_clear_mac(void *np, unsigned long reg,
				     int limit, int delay)
{
 ...

#define niu_wait_bits_clear_mac(NP, REG, LIM, DELAY) \
({	BUILD_BUG_ON(LIM <= 0 || DELAY < 0); \
	__niu_wait_bits_clear_mac(NP, REG, LIM, DELAY); \
})
