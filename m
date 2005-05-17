From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 12:13:35 -0700
Message-ID: <428A425F.7000807@hp.com>
References: <Pine.LNX.4.61.0505170914130.29021@linux.site>	<20050517.104947.112621738.davem@davemloft.net>	<m1zmut7l5q.fsf@muc.de> <428A3F86.1020000@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <428A3F86.1020000@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> This is a fast LAN problem - real internet latencies
> don't allow for the wrapping of the id field that fast.

What is a "fast" LAN these days?  We were seeing IP ID wrap with NFS traffic 
back in the time of HP-UX 8.07 (early 1990's) over 10 Mbit/s Ethernet.  Since 
I'm waxing historic, part of the problem at that time was giving the IP 
fragments to the driver one at a time rather than all at once.  When the system 
was as fast or faster than the network, and the driver queue filled, the first 
couple fragments of a datagram would get into the queue, and the rest would be 
dropped, setting the stage for those wonderful Frankengrams.  Part of the fix 
was to require a driver to take an entire IP datagram's worth of fragments or 
none of them.

And there was at least one CKO NIC from that era (the HP-PB FDDI NIC) where the 
first IP datagram fragment was sent last :)

If the WAN connected system is (still?) using a global IP ID rather than 
per-route, it could quite easily be wrapping.  And we have WAN links with 
bandwidths of 10's of Megabits, so it also comes-down to how much other traffic 
is going and the quantity of request parallelism in NFS right?

The larger NFS UDP mount sizes mean more fragments, but intriguingly, they also 
mean slower wrap of the IP ID space :)

rick jones
