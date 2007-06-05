From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] UDP : bind() checks are not complete
Date: Tue, 05 Jun 2007 13:02:19 -0700 (PDT)
Message-ID: <20070605.130219.35356925.davem@davemloft.net>
References: <20070605191536.cc9a4719.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49986
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763003AbXFEUCF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 16:02:05 -0400
In-Reply-To: <20070605191536.cc9a4719.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 5 Jun 2007 19:15:36 +0200

> I discovered one big problem with UDP binding in 2.6.22-rc4 :

Thanks for finding this problem, the crux of the issue is
INADDR_ANY.

> We really should check no socket is bound to XXX.XXX.XXX.XXX:32769. With current hashing, 
> it means checking all slots in udptable[] :(
> 
> Our choices are :
> 
> 1) Drop all thoses patches and re-think them for 2.6.23 eventually
> 2) Add the extra check for ANY_ADDR sockets and perform a full scan
> 
> What do you think ?

Does checking for INADDR_ANY sockets really require a full scan?
It should just need two hash probes as far as I can tell to see
if there is "0.0.0.0:PORT" bound already.
