From: Christian Schmid <webmaster@rapidforum.com>
Subject: Re: Annoying bug with many sockets.
Date: Mon, 21 Feb 2005 01:35:33 +0100
Message-ID: <42192CD5.5090401@rapidforum.com>
References: <421925DB.2060602@rapidforum.com> <42192AAF.8020609@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <42192AAF.8020609@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Nivedita Singhvi wrote:
> Christian Schmid wrote:
> 
>> Hi.
>>
>> This is really annoying. With 3500 sockets onwards, linux 2.6.10 
>> completely lags. This is a bug and I am not willing to buy new servers 
>> just because linux has a BUG. tcp_mem _rmem and _wmem have been set to 
>> 1024000 for testing but this doesnt help as well. so whats WRONG 
>> there... please?
>>
>> Best regards,
>> Chris
> 
> 
> You have not actually said what the problem is - do
> new connections not get made? Or existing connections
> slow down?

New connections get made without any problems. Just existing connections slow down painfully.

> You are trying to run many simultaneous connections, so
> bumping up the individual socket buffer allocation will
> not necessarily help - you need to bump up the global
> TCP limit (tcp_mem[]) - it's a 3-tuple - if you have
> the memory in your system, bump it way up. netstat -tan
> will tell you if there is unread data in the queues..

I already set it to 1024000 1025000 1026000 (just to be sure). Its a 8 GB system with 2/2 split, so 
2 GB of low memory.

> Are you running into memory pressure? Or aborts?
> netstat -s might give you some info on what is happening.
> 
> Bump up the port space (/proc/sys/net/ipv4/ip_local_port_range)
> available - typical default is 32K - 61000 (can lower min to 4K)
> 
> Are they all receiving data or sending? Are they talking to
> different hosts?
> 
> You can increase tcp_max_syn_backlog, core/netdev_max_backlog,
> for a start.

netdev_max_backlog has been raised from 300 to 3000 without any result. syn_backlog is normal but 
its no problem to create new connections. Just existing connections slow down suddenly. Like this:

3000 sockets = no slowdown at all (500 MBit in use)
3300 sockets = 10% slowdown
3600 sockets = 30% slowdown
4000 sockets = 60% slowdown (i aborted here, as it only uses 200 MBit for sending... catastrophy!)

They are all receiving data. Its a download-service. receive-buffer is set to 24 KB and send-buffer 
set to 224 KB. I don't see a problem with port-space. I only have 3500 sockets when the problem 
appears but it appears suddenly.

> But it would help if you looked at the stats and ifconfig
> to see who's dropping packets, how many retransmissions there
> are, memory failures, or the bottleneck is some other issue altogether...

No way. Doing 30000 packets per second and your stats are 32 bit integers ;)

Chris
