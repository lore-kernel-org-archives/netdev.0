From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: TOE brain dump
Date: Sat, 02 Aug 2003 15:08:52 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F2C0C44.6020002@pobox.com>
References: <20030802140444.E5798@almesberger.net> <3F2BF5C7.90400@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Werner Almesberger <werner@almesberger.net>, netdev@oss.sgi.com,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <3F2BF5C7.90400@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

My own brain dump:

If one wants to go straight from disk to network, why is anyone 
bothering to involve the host CPU and host memory bus at all?  Memory 
bandwidth and PCI bus bandwidth are still bottlenecks, no much how much 
of the net stack you offload.


Regardless of how fast your network zooms packets, you've gotta keep 
that pipeline full to make use of it.  And you've gotta do something 
intelligent with it, which in TCP's case involves the host CPU quite a 
bit.  TCP is sufficiently complex, for a reason.  It has to handle all 
manner of disturbingly slow and disturbing fast net connections, all 
jabbering at the same time.  TCP is a "one size fits all" solution, but 
it doesn't work well for everyone.

The "TCP Offload Everything" people really need to look at what data 
your users want to push, at such high speeds.  It's obviously not over a 
WAN...  so steer users away from TCP, to an IP protocol that is tuned 
for your LAN needs, and more friendly to some sort of h/w offloading 
solution.

A "foo over ipv6" protocol that was designed for h/w offloading from the 
start, would be a far better idea than full TCP offload will ever be.

In any case, when you approach these high speeds, you really must take a 
good look at the other end of the pipeline:  what are you serving at 
10Gb/s, 20Gb/s, 40Gb/s?  For some time, I think the answer will be 
"highly specialized stuff"  At some point, Intel networking gear will be 
able to transfer more bits per second than there exist atoms on planet 
Earth :)  Garbage in, garbage out.

So, fix the other end of the pipeline too, otherwise this fast network 
stuff is flashly but pointless.  If you want to serve up data from disk, 
then start creating PCI cards that have both Serial ATA and ethernet 
connectors on them :)  Cut out the middleman of the host CPU and host 
memory bus instead of offloading portions of TCP that do not need to be 
offloaded.

	Jeff
