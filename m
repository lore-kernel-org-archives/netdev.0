From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] net: export the number of times the recv queue was full
Date: Thu, 10 Dec 2009 14:13:09 -0800
Message-ID: <4B217275.9050104@hp.com>
References: <20091210210920.6820.12664.stgit@paris.rdu.redhat.com>	<4B216A61.7020704@hp.com> <1260481947.2784.33.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Paris <eparis@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:12730 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761757AbZLJWNF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 17:13:05 -0500
In-Reply-To: <1260481947.2784.33.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Paris wrote:
> On Thu, 2009-12-10 at 13:38 -0800, Rick Jones wrote:
> 
>>Eric Paris wrote:
>>
>>>We got a request in which a customer was trying to determine how often their
>>>recieve queue was full and thus they were sending a zero window back to the
>>>other side.  By the time they would notice the slowdowns they would have all
>>>empty receive queues and wouldn't know which socket was a problem. 
>>
>>Wouldn't a tcpdump command with suitable filter expression on the window field 
>>of the TCP header do?
> 
> 
> It could as a post processing measure be used to find this situation.  I
> believe they want a more 'on the fly' method.

If tcpdump is runnable/running while all this is going-on, with the suitable 
filter expression they will be getting the four tuple of local/remote IP, 
local/remote port with which to identify the endpoints where this is happening. 
Pipe the tcpudmp output to a script that does the connection lookup via 
lsof/whatnot. And not only will they know which and how often, but *when*, and 
they can perhaps then correlate with other statistics to figure-out why the 
application was not keeping-up with the incoming traffic and so address root 
cause rather than symptom.

In theory, this (sans the immediate connection lookup) could even be done with a 
third system connected to a monitor port on the same switch as the server(s) in 
question, and not add any additional overhead to the servers, which if the 
application(s) are not keeping up may be somewhat CPU saturated already?

rick jones
