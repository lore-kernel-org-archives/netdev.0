From: "Chad N. Tindel" <chad@tindel.net>
Subject: Re: udp_recvmsg: possible bug causing infinite hang?
Date: Tue, 12 Oct 2004 01:32:33 -0400
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20041012053233.GB62811@calma.pair.com>
References: <20041009184503.7fc5c105.davem@davemloft.net> <Pine.LNX.4.44.0410121052390.29592-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Nagendra Singh Tomar <nagendra_tomar@adaptec.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0410121052390.29592-100000@localhost.localdomain>
List-Id: netdev.vger.kernel.org

> Does the POSIX standard _not_ give this implicit guarantee ? Whats the 
> point in having a select call that says that the fd is readable, and when 
> I go to read it the blocking read call blocks. Then either select returned 
> a wrong positive or the read is buggy. 
> 	The kernel should mark the socket readable (and hence select returns 
> "readable") only after it has added the incoming data to the socket receive 
> queue or it has changed the state of the socket (in case of TCP connections 
> getting closed), in case of peer closing the connection.
> After that has been done, is the guarantee not there ?

What you're saying is correct.  However, if the UDP handler pulls the data
off of the receive queue and then finds that the datagram is corrupted, it
will go back into the read function to wait for another datagram.  Personally
I think that it should return some other kind of error (not EAGAIN) to indicate
somehow that we discarded a datagram due to a bad checksum.

Chad
