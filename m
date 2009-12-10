From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: export the number of times the recv queue was full
Date: Thu, 10 Dec 2009 13:48:07 -0800 (PST)
Message-ID: <20091210.134807.54217873.davem@davemloft.net>
References: <20091210210920.6820.12664.stgit@paris.rdu.redhat.com>
	<4B216A61.7020704@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eparis@redhat.com, netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43362
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761743AbZLJVsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 16:48:00 -0500
In-Reply-To: <4B216A61.7020704@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Thu, 10 Dec 2009 13:38:41 -0800

> Eric Paris wrote:
>> We got a request in which a customer was trying to determine how often
>> their
>> recieve queue was full and thus they were sending a zero window back
>> to the
>> other side.  By the time they would notice the slowdowns they would
>> have all
>> empty receive queues and wouldn't know which socket was a problem. 
> 
> Wouldn't a tcpdump command with suitable filter expression on the
> window field of the TCP header do?
> 
>> It also
>> allows them to find the sockets in which they need to up the recv
>> queue size
>> rather than doing it for all sockets across the box. 
> 
> Doesn't Linux by default "autotune" the socket buffers? (Or perhaps is
> that how they got zero windows from time to time anyway?)

The window will "autotune" only if the connection is not application
limited.

Their applications, therefore, by definition are getting filled up
receive queues because it is busy doing something other than reading
from the socket when data arrives (disk I/Os, etc.)
