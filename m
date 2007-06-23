From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFD] L2 Network namespace infrastructure
Date: Sat, 23 Jun 2007 13:09:49 -0700
Message-ID: <467D7E0D.7060206@candelatech.com>
References: <m1tzszbwyb.fsf@ebiederm.dsl.xmission.com>	<467CF8AC.80103@trash.net> <467D3A48.20706@candelatech.com> <m14pkya8fv.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, jamal <hadi@cyberus.ca>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Linux Containers <containers@lists.osdl.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:52824 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751702AbXFWUQ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jun 2007 16:16:57 -0400
In-Reply-To: <m14pkya8fv.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Ben Greear <greearb@candelatech.com> writes:
>
>   
>> Will we be able to have a single application be in multiple name-spaces?
>>     
>
> A single application certainly.   But then an application can be composed
> of multiple processes which can be composed of multiple threads.
>
> In my current patches a single task_struct belongs to a single network
> namespace.  That namespace is used when creating sockets.  The sockets
> themselves have a namespace tag and that is used when transmitting
> packets, or otherwise operating on the socket.
>
> So if you pass a socket from one process to another you can have
> sockets that belong to different network namespaces in a single task.
>   
Any chance it could allow one to use a single threaded, single process 
and do something like
int fd1 = socket(...., namespace1);
int fd2 = socket(...., namespace2);

Or, maybe a sockopt or similar call to move a socket into a particular 
namespace?

I can certainly see it being useful to allow a default name-space per 
process, but it would be nice
to also allow explicit assignment of a socket to a name-space for 
applications that want to span
a large number of name-spaces.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


