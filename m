From: David Miller <davem@davemloft.net>
Subject: Re: loaded router, excessive getnstimeofday in oprofile\
Date: Wed, 27 Aug 2008 15:23:14 -0700 (PDT)
Message-ID: <20080827.152314.218610441.davem@davemloft.net>
References: <20080827165635.GY26610@one.firstfloor.org>
	<48B58E6B.1030302@cosmosbay.com>
	<20080827183216.GZ26610@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, rick.jones2@hp.com, johnpol@2ka.mipt.ru,
	denys@visp.net.lb, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49795
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752813AbYH0WXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 18:23:19 -0400
In-Reply-To: <20080827183216.GZ26610@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Wed, 27 Aug 2008 20:32:16 +0200

> > Doing the expensive timestamping in a possibly delayed thread (ie some 
> > milliseconds
> > after hardware notification) is wrong/useless.
> 
> We had this discussion earlier, please review the thread I linked to. 
> 
> Note that interrupts can be arbitarily delayed too (both by cli
> and by interrupt mitigation), even on a non RT kernel.

This is a much different kind of delay compared to sleeping for seconds
or longer on the socket lock while a GFP_KERNEL allocation is being
satisfied by swapping tons of crap out to disk.

Your socket solution is not a workable scheme.
