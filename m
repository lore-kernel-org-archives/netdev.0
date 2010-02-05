From: Cong Wang <amwang@redhat.com>
Subject: Re: [RFC Patch] net: reserve ports for applications using fixed port
 	numbers
Date: Fri, 05 Feb 2010 15:25:24 +0800
Message-ID: <4B6BC7E4.5070909@redhat.com>
References: <20100203043332.3817.27932.sendpatchset@localhost.localdomain> <e2e108261002042311w59ba1372ld9f8fb2f369ca434@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-sctp@vger.kernel.org, David Miller <davem@davemloft.net>
To: Bart Van Assche <bvanassche@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59545 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932913Ab0BEHWJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Feb 2010 02:22:09 -0500
In-Reply-To: <e2e108261002042311w59ba1372ld9f8fb2f369ca434@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bart Van Assche wrote:
> On Wed, Feb 3, 2010 at 5:30 AM, Amerigo Wang <amwang@redhat.com> wrote:
>> This patch introduces /proc/sys/net/ipv4/ip_local_reserved_ports,
>> it can be used like ip_local_port_range, but this is used to
>> reserve ports for third-party applications which use fixed
>> port numbers within ip_local_port_range.
>>
>> This only affects the applications which call socket functions
>> like bind(2) with port number 0, to prevent the kernel getting the ports
>> within the specified range for them. For applications which use fixed
>> port number, it will have no effects.
>>
>> Any comments are welcome.
> 
> Relying on fixed port numbers is generally considered as a shortcoming
> in the application. It would be helpful if you could explain more in
> detail why port number reservation is necessary. Maybe there exists
> another solution that does not require modifying the bind() system
> call.
> 

The problem is that there are some existing applications which use
fixed port number, we don't have chances to change this for them,
thus making them working is desired, so they want to reserve these
port for those applications.

For example, if I have an appliction which uses port 40000, but
before this application starts, another application gets this port
number by bind() with port 0 (i.e. chosen by kernel), in this case,
that application will fail to start. Again, we don't have any chance
to change the source code of that application.

Hope this can make the problem clear.

Thanks.

