From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][SOCK]: shrink struct sock
Date: Thu, 03 May 2007 21:22:27 -0700 (PDT)
Message-ID: <20070503.212227.74561366.davem@davemloft.net>
References: <20070504041101.GA27519@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43538
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754317AbXEDEW1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 00:22:27 -0400
In-Reply-To: <20070504041101.GA27519@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Fri, 4 May 2007 01:11:01 -0300

> 
> 	This saves 8 bytes out of struct sock in 64bit arches, tested on x86_64.

Thanks I'll apply this.

> Now struct sock has this layout, where we waste more 20 bytes, in four 4 byte
> paddings in struct skb_buff_head members (layout at the bottom) + one 4 bytes
> hole:

sk_buff_head is due for being killed from the whole tree.  Nobody
really needs the qlen, few things really need the lock, and those that
do can define their own as needed :-)

There are also cases where we don't even need to dual-linkage so could
decrease it down to one pointer.
