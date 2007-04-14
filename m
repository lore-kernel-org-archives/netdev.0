From: David Miller <davem@davemloft.net>
Subject: Re: TCP connection stops after high load.
Date: Fri, 13 Apr 2007 22:37:39 -0700 (PDT)
Message-ID: <20070413.223739.27452745.davem@davemloft.net>
References: <E1HcZlg-0006Bi-00@gondolin.me.apana.org.au>
	<46206737.8000307@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, danielschaffrath@mac.com,
	greearb@candelatech.com, andi@firstfloor.org,
	netdev@vger.kernel.org, bcrl@kvack.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56922
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161098AbXDNFhi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Apr 2007 01:37:38 -0400
In-Reply-To: <46206737.8000307@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sat, 14 Apr 2007 07:31:35 +0200

> When did tg3 model changed exactly ?

June of 2006:

commit 00b7050426da8e7e58c889c5c80a19920d2d41b3
Author: Michael Chan <mchan@broadcom.com>
Date:   Sat Jun 17 21:58:45 2006 -0700

    [TG3]: Convert to non-LLTX
    
    Herbert Xu pointed out that it is unsafe to call netif_tx_disable()
    from LLTX drivers because it uses dev->xmit_lock to synchronize
    whereas LLTX drivers use private locks.
    
    Convert tg3 to non-LLTX to fix this issue. tg3 is a lockless driver
    where hard_start_xmit and tx completion handling can run concurrently
    under normal conditions. A tx_lock is only needed to prevent
    netif_stop_queue and netif_wake_queue race condtions when the queue
    is full.
    
    So whether we use LLTX or non-LLTX, it makes practically no
    difference.
    
    Signed-off-by: Michael Chan <mchan@broadcom.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
