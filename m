From: Steven Whitehouse <steve@gw.chygwyn.com>
Subject: Re: [patch] add iocb to network protocols
Date: Fri, 11 Oct 2002 10:31:23 +0100 (BST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200210110931.KAA19428@gw.chygwyn.com>
References: <20021010183528.A13432@redhat.com>
Reply-To: Steve Whitehouse <Steve@ChyGwyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bcrl@redhat.com (Benjamin LaHaise)
In-Reply-To: <20021010183528.A13432@redhat.com> from "Benjamin LaHaise" at Oct 10, 2002 06:35:29 PM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

> 
> Hello Dave,
> 
> Below is a copy of the bk tree at:
> 
> 	bk pull master.kernel.org:/home/bcrl/net-2.5
> 
> This tree adds the iocb parameter into the sendmsg and recvmsg 
> operations within the network operations.  sock_read and sock_write 
> are also replaced by sock_aio_read/sock_aio_write, so this requires 
> the other aio changes to fs/read_write.c that are in fresh trees 
> from Linus.  Comments?
>
[patch etc. cut]

I have a few questions about the way aio interacts with the socket locking
and the consequences for atomicity of requests:

Given two aio requests, A and B both for the same socket, can I be sure
that they will complete in the order that I submit them ? Can I also
be sure that parts of the I/O request for A will not be mixed up with
B ? Will that still be true if one of the requests is aio and one a "normal"
send/recvmsg() for example ?

Currently with multiple sendmsg() calls (for example) because the socket
lock is dropped to allow packet delivery to the socket during periods of
waiting for events, it would be possible for our two I/O requests A and B
to be interleaved so that B could be sent out sandwiched between two
parts of request A. Of course you have to submit the I/O from separate
threads for this to happen, but I'm wondering what the implications are 
for aio in this area. Do the standards have anything to say in this area ?

Steve.
