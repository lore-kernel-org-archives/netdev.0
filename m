From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp_sendpage(): fix broken page iteration
Date: Sun, 18 Mar 2007 14:49:27 -0700 (PDT)
Message-ID: <20070318.144927.78708843.davem@davemloft.net>
References: <20070318124346.GA6396@localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: da-x@monatomic.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43722
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933280AbXCRVt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2007 17:49:27 -0400
In-Reply-To: <20070318124346.GA6396@localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Aloni <da-x@monatomic.org>
Date: Sun, 18 Mar 2007 14:43:46 +0200

> do_tcp_sendpages() should not iterate 'pages' as an array since 
> it is not an array of 'struct page *', but a pointer to a single 
> entity of 'struct page *' passed on the stack as a parameter to 
> tcp_send_page() (hence it would crash if poffset + psize > PAGE_SIZE,
> because pages[1] and beyond most probably not constitutes a valid 
> 'struct page *').

do_tcp_sendpages() should never get passed poffset+psize>PAGE_SIZE,
that would be a bug.

Feel free to add a BUG() check for that if you wish, and a fix for any
caller which violates this.

The code is perfectly fine as-is.  It was originally written to accept
page arrays, but once it was decided that ->sendpage() would only pass
in one page, we simply modified to caller of do_tcp_sendpages() to
accomodate this argument passing change, instead of changing
do_tcp_sendpages() which is totally unnecessary.
