From: Alexey Toptygin <alexeyt@freeshell.org>
Subject: kernel-manpage inconsistency
Date: Wed, 14 Jul 2004 22:04:25 +0000 (UTC)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.NEB.4.60.0407142202270.24397@ukato.freeshell.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I don't know wether this is a kernel issue or a manpage issue, I just know that 
they disagree.

In recv(2) it says:

     MSG_TRUNC
 	Return  the  real  length of the packet, even when it was longer
 	than the passed buffer. Only valid for packet sockets.

But this is not honored.

Also, in udp(7), it says:

IOCTLS
     These ioctls can be accessed using ioctl(2).  The correct syntax is:

 	int value;
 	error = ioctl(tcp_socket, ioctl_type, &value);

     SIOCINQ
 	Gets a pointer to an integer as argument. Returns  the  size  of
 	the  next pending datagram in the integer in bytes, or 0 when no
 	datagram is pending.

     SIOCOUTQ
 	Returns the number of data bytes in the local send  queue.  Only
 	supported with Linux 2.4 and above.

These don't appear to be implemented. ( They're not in any headers and they're 
not listed in ioctl_list(2). )

Please tell me who I need to report this to to get it fixed.

Also, if there is a way to get the length of the next incoming datagram, I 
would love to know about it. Currently I'm resorting to:

while(1){
 	recvmsg(..., MSG_PEEK);
 	if ( flags & MSG_TRUNC ){
 		double buffer size;
 	} else {
 		break;
 	}
}

 			Alexey

P.S. I'm not on the list, please reply directly. Thanks.
