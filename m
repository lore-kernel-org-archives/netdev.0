From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Thu, 30 Oct 2008 00:05:55 -0700 (PDT)
Message-ID: <20081030.000555.206423691.davem@davemloft.net>
References: <20081029.224027.163185414.davem@davemloft.net>
	<49094B79.4010805@cosmosbay.com>
	<49095C8A.403@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, minyard@acm.org, shemminger@vyatta.com,
	benny+usenet@amorsen.dk, netdev@vger.kernel.org,
	cl@linux-foundation.org, a.p.zijlstra@chello.nl,
	johnpol@2ka.mipt.ru, christian@myri.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48458
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751450AbYJ3HGV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 03:06:21 -0400
In-Reply-To: <49095C8A.403@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 30 Oct 2008 08:04:42 +0100

> If we design something that could be reused, say for TCP sockets, we need
> to be able to handle very large number of 'NULL' pointers, say, up to 64*1024*1024
> 
> So lets use the low order bit, set to one for "NULL" pointers, and 0 for regular pointers.
> 
> This gives us 31 bits (or 63 bits) to store any valuable info :)
> 
> and all ...._nulls() macros would not need to know the max value (UDP_HTABLE_SIZE in UDP case),
> since all they have to do is a test ((unsigned long)pos & 1)
> 
> At iterator exit, pos would contain the 'index' value, (pos >> 1), to hide this
> implementation detail.

This sound fine to me.  Quite an improvement in fact :)

