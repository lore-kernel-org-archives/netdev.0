From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] net: export the number of times the recv queue was full
Date: Thu, 10 Dec 2009 13:38:41 -0800
Message-ID: <4B216A61.7020704@hp.com>
References: <20091210210920.6820.12664.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Paris <eparis@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:3102 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755457AbZLJVig (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 16:38:36 -0500
In-Reply-To: <20091210210920.6820.12664.stgit@paris.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Paris wrote:
> We got a request in which a customer was trying to determine how often their
> recieve queue was full and thus they were sending a zero window back to the
> other side.  By the time they would notice the slowdowns they would have all
> empty receive queues and wouldn't know which socket was a problem. 

Wouldn't a tcpdump command with suitable filter expression on the window field 
of the TCP header do?

> It also
> allows them to find the sockets in which they need to up the recv queue size
> rather than doing it for all sockets across the box. 

Doesn't Linux by default "autotune" the socket buffers? (Or perhaps is that how 
they got zero windows from time to time anyway?)

Or does this customer's application(s) bypass that by making explicit 
setsockopt() calls, and presumably have a way to tell the application(s) on a 
destination by destination basis which connections to increase?

More generically, zero window means the application isn't calling read/recv fast 
enough right?  Or is it "known" that the traffic the applcation is receiving is 
bursty and this isn't a sustained overload situation?

rick jones
