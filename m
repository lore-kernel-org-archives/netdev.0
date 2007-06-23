From: Carl-Daniel Hailfinger <c-d.hailfinger.devel.2006@gmx.net>
Subject: Re: [RFD] L2 Network namespace infrastructure
Date: Sat, 23 Jun 2007 22:19:34 +0200
Message-ID: <467D8056.1000307@gmx.net>
References: <m1tzszbwyb.fsf@ebiederm.dsl.xmission.com>	<467CF8AC.80103@trash.net> <m1bqf6a8rd.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, Jeff Garzik <jeff@garzik.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Linux Containers <containers@lists.osdl.org>,
	Ben Greear <greearb@candelatech.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:39020 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751833AbXFWUSn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jun 2007 16:18:43 -0400
In-Reply-To: <m1bqf6a8rd.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23.06.2007 19:19, Eric W. Biederman wrote:
> Patrick McHardy <kaber@trash.net> writes:
> 
>> Eric W. Biederman wrote:
> 
>>> Depending upon the data structure it will either be modified to hold
>>> a per entry network namespace pointer or it there will be a separate
>>> copy per network namespace.  For large global data structures like
>>> the ipv4 routing cache hash table adding an additional pointer to the
>>> entries appears the more reasonable solution.
>>
>> So the routing cache is shared between all namespaces?
> 
> Yes.  Each namespaces has it's own view so semantically it's not
> shared.  But the initial fan out of the hash table 2M or something
> isn't something we want to replicate on a per namespace basis even
> assuming the huge page allocations could happen.
> 
> So we just tag the entries and add the network namespace as one more
> part of the key when doing hash table look ups.

Can one namespace DoS other namespaces' access to the routing cache?
Two scenarios come to mind:
* provoking hash collisions
* lock contention (sorry, haven't checked whether/how we do locking)

Regards,
Carl-Daniel
