From: David Miller <davem@davemloft.net>
Subject: Re: for 3.0 : please add "c16a98e ipv6: tcp: fix panic in SYN
 processing"
Date: Fri, 18 Oct 2013 13:31:19 -0400 (EDT)
Message-ID: <20131018.133119.2049409060286197552.davem@davemloft.net>
References: <20131018140442.GA16883@1wt.eu>
	<20131018143433.GA27502@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w@1wt.eu, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	stable@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20131018143433.GA27502@kroah.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 18 Oct 2013 07:34:33 -0700

> On Fri, Oct 18, 2013 at 04:04:42PM +0200, Willy Tarreau wrote:
>> Greg, David,
>> 
>> one of our customers faced a panic in latest 2.6.32 when both somaxconn
>> and the listen backlog are large on an IPv6 socket. It was also reported
>> by one haproxy user on the latest RHEL6 kernel a few months ago. We found
>> that the same bug affects 3.0 up to and including 3.0.100.
>> 
>> Eric had already spotted that bug and fixed it in 3.2 with the following
>> patch :
>> 
>>   commit c16a98ed91597b40b22b540c6517103497ef8e74
>>   Author: Eric Dumazet <eric.dumazet@gmail.com>
>>   Date:   Wed Nov 23 15:49:31 2011 -0500
>> 
>>     ipv6: tcp: fix panic in SYN processing
>>     
>>     commit 72a3effaf633bc ([NET]: Size listen hash tables using backlog
>>     hint) added a bug allowing inet6_synq_hash() to return an out of bound
>>     array index, because of u16 overflow.
>>     
>>     Bug can happen if system admins set net.core.somaxconn &
>>     net.ipv4.tcp_max_syn_backlog sysctls to values greater than 65536
>>     
>>     Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>>     Signed-off-by: David S. Miller <davem@davemloft.net>
>> 
>> In practice, the bug extends to lower values as well (32768 and above),
>> because reqsk_queue_alloc() can round the number of entries to double of
>> the backlog by doing roundup_pow_of_two(backlog+1), resulting in
>> inet6_csk_search_req() calling inet6_synq_hash() with too large an integer.
>> 
>> Could we please apply it to 3.0 before it finishes its life ?
> 
> Unless David objects, I can queue this up just in time for the last
> 3.0.stable.
> 
> David?

No objections.
