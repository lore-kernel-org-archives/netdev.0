From: David Miller <davem@davemloft.net>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Tue, 17 Jun 2008 17:02:26 -0700 (PDT)
Message-ID: <20080617.170226.132179445.davem@davemloft.net>
References: <20080526.151540.191673092.davem@davemloft.net>
	<483BA80C.4020502@krogh.cc>
	<483CB301.40007@sun.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesper@krogh.cc, yhlu.kernel@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Matheos.Worku@Sun.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58254
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754343AbYFRACZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 20:02:25 -0400
In-Reply-To: <483CB301.40007@sun.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matheos Worku <Matheos.Worku@Sun.COM>
Date: Tue, 27 May 2008 18:18:57 -0700

> Considering that fixing the HW would take considerable time, I was 
> wondering if the scheme we use in the nxge driver could be considered as 
> a workaround. Since the niu driver is already doing skb_orphan as a work 
> around, what if  already transmitted TX buffers are  reclaimed 
> periodically, within dev->hard_start_xmit() ?  Then TX_DESC_MARK would 
> be set if/when available TX descriptor count falls below some watermark. 
> Disable device TX queue about the time  TX_DESC_MARK is set and enable 
> it within TX interrupt.

This is still insufficient.

Even if we detach the socket association, there are still resources
held by the SKB, such as firewalling state.

So you can get into situations where, for example, you can't unload
netfilter modules, attempts just hang the system.

The only workaround is to use a timer to purge the TX queue, and that's
far from acceptable in my opinion, because of the timer maintainence
overhead and the latency.

