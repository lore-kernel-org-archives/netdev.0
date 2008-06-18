From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix corrupt TCP packets when options space overflows
 with MD5SIG enabled (v2)
Date: Wed, 18 Jun 2008 15:01:04 -0700 (PDT)
Message-ID: <20080618.150104.147203818.davem@davemloft.net>
References: <20080618023446.aba6516c.billfink@mindspring.com>
	<20080618.015206.22767411.davem@davemloft.net>
	<396556a20806181239q30024b8bv551f76a890befb0e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: billfink@mindspring.com, netdev@vger.kernel.org
To: agl@imperialviolet.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39196
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754065AbYFRWBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 18:01:04 -0400
In-Reply-To: <396556a20806181239q30024b8bv551f76a890befb0e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Adam Langley" <agl@imperialviolet.org>
Date: Wed, 18 Jun 2008 12:39:03 -0700

> On Wed, Jun 18, 2008 at 1:52 AM, David Miller <davem@davemloft.net> wrote:
> > It's pretty easy, depending upon the timestamp resolution, to
> > end up with the original transmit and the retransmit having
> > the same timetsamp value.  So this suggestion in the RFC is
> > I think not a complete solution.
> 
> I happen to have just (unintentionally) simulated this, i.e. a
> situation where MD5 signed packets with SACKs were dropped by the
> receiving host. The transmitting host keeps sending packets with SACKs
> and they keep getting dropped: the connection stalled.

The retransmit timeout timer has to fire eventually, and when
that happens we should clear all of our SACK state.

I'm not denying your observations, I'm just stating what ought
to be happening.
