From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: Send-Q not being emptied
Date: Sat, 04 Jan 2003 17:10:56 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E178620.53128BE6@us.ibm.com>
References: <3E1702F2.9000105@us.ibm.com>
Reply-To: niv@us.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Dave Hansen <haveblue@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave Hansen wrote:
> 
> I'm seeing some strange behavior running Specweb99 with
> 2.4.19-64GB-SMP on the clients, and 2.5.50 on the server.  I'm using
> Apache/2.0.43.  The load is fairly low, ~1000 (this is an 8-way P4).
> 
> The client program is sitting blocked on a socket read().  It's
> netstat entry looks like this (I clipped off the PID/Program part):
> Recv-Q Send-Q Local Address       Foreign Address      State
>       0      0 192.168.1.100:35486 192.168.1.1:80       ESTABLISHED
> The server side's netstat (httpd):
>       0 120184 192.168.1.1:80      192.168.1.100:35486  ESTABLISHED

> It will stay like this for several minutes at a time, until the
> Specweb99 client program usually times out complaining with something
> like this:
> Sat Jan  4 10:05:28 2003 HTTPGetReply: got 272144, expected 614400
> 
> But, this doesn't always happen to the client, and sometimes it will
> stay blocking on that socket read() forever.  This keeps me from
> getting any completed benchmark runs because there are always 1 or two
> of these stragglers.

hmmm, send side window was closed and we lost an update? or we
had a lot of successive drops and we're backed off and client 
terminated before we retransmitted?

but, why doesnt the client time out in all instances? is the send
side always still around in established state? if the sending thread
got killed for some reason, the client might have gotten a reset back..

> Why isn't the client's read ever completing, even if the server has
> data in its send queue?  I'm sure that the cable is plugged in :)

you've probably turned off sack etc, right? what are your settings?
taking a look at the stats would be useful..also tried pinging just
to make sure the interface is still up and not jammed? 

thanks,
Nivedita
