From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: Annoying bug with many sockets.
Date: Sun, 20 Feb 2005 16:26:23 -0800
Message-ID: <42192AAF.8020609@us.ibm.com>
References: <421925DB.2060602@rapidforum.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Christian Schmid <webmaster@rapidforum.com>
In-Reply-To: <421925DB.2060602@rapidforum.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christian Schmid wrote:

> Hi.
> 
> This is really annoying. With 3500 sockets onwards, linux 2.6.10 
> completely lags. This is a bug and I am not willing to buy new servers 
> just because linux has a BUG. tcp_mem _rmem and _wmem have been set to 
> 1024000 for testing but this doesnt help as well. so whats WRONG 
> there... please?
> 
> Best regards,
> Chris

You have not actually said what the problem is - do
new connections not get made? Or existing connections
slow down?

You are trying to run many simultaneous connections, so
bumping up the individual socket buffer allocation will
not necessarily help - you need to bump up the global
TCP limit (tcp_mem[]) - it's a 3-tuple - if you have
the memory in your system, bump it way up. netstat -tan
will tell you if there is unread data in the queues..

Are you running into memory pressure? Or aborts?
netstat -s might give you some info on what is happening.

Bump up the port space (/proc/sys/net/ipv4/ip_local_port_range)
available - typical default is 32K - 61000 (can lower min to 4K)

Are they all receiving data or sending? Are they talking to
different hosts?

You can increase tcp_max_syn_backlog, core/netdev_max_backlog,
for a start.

But it would help if you looked at the stats and ifconfig
to see who's dropping packets, how many retransmissions there
are, memory failures, or the bottleneck is some other issue altogether...


thanks,
Nivedita
