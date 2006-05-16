From: Rick Jones <rick.jones2@hp.com>
Subject: Re: send(), sendmsg(), sendto() not thread-safe
Date: Mon, 15 May 2006 17:02:35 -0700
Message-ID: <4469169B.401@hp.com>
References: <OFE8460E54.0C8D85D8-ON8525716F.0074F22F-8825716F.0076D537@us.ibm.com>	<20060515.154939.28171388.davem@davemloft.net>	<44690C1C.8030101@hp.com> <20060515163545.4e3d755a@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mark1smi@us.ibm.com, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:33754 "EHLO palrel13.hp.com")
	by vger.kernel.org with ESMTP id S1750838AbWEPACi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 May 2006 20:02:38 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060515163545.4e3d755a@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>I presume this is only for "blocking" sockets?  I cannot at least off 
>>the top of my head see how a stack could offer it on non-blocking sockets.
> 
> 
> The test seems to be based on sending a big message. In this case,
> on non-blocking sockets, the send call will return partial status. The
> return from the system call will be less than the number of bytes requested.

Right, and at that point it is already too late to do anything about 
keeping some other thread of execution from shoving _its_ bytes into the 
socket before the rest of the first sends' can be put there.

(Perhaps I'm preaching to the choir)

rick jones
