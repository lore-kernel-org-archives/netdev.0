From: "Michael T Kerrisk" <mtk-lists@gmx.net>
Subject: Re: kernel-manpage inconsistency
Date: Thu, 15 Jul 2004 14:51:35 +0200 (MEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4407.1089895895@www4.gmx.net>
References: <Pine.NEB.4.60.0407142202270.24397@ukato.freeshell.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexey Toptygin <alexeyt@freeshell.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello Alexey,

> I don't know wether this is a kernel issue or a manpage issue, I just 
> know that they disagree.
> 
> In recv(2) it says:
> 
>      MSG_TRUNC
>  	Return  the  real  length of the packet, even when it was longer
>  	than the passed buffer. Only valid for packet sockets.
> 
> But this is not honored.

I don't know the details here, sorry.  A quick glance at the source
(raw_recvmsg() in net/ipv4/raw.c) shows that MSG_TRUNC is used there.

> Also, in udp(7), it says:
> 
> IOCTLS
>      These ioctls can be accessed using ioctl(2).  The correct syntax is:
> 
>  	int value;
>  	error = ioctl(tcp_socket, ioctl_type, &value);
> 
>      SIOCINQ
>  	Gets a pointer to an integer as argument. Returns  the  size  of
>  	the  next pending datagram in the integer in bytes, or 0 when no
>  	datagram is pending.
> 
>      SIOCOUTQ
>  	Returns the number of data bytes in the local send  queue.  Only
>  	supported with Linux 2.4 and above.
> 
> These don't appear to be implemented. ( They're not in any headers and
> they're not listed in ioctl_list(2). )

They're names in the kernel source.  In userland, FIONREAD and TIOCOUTQ will
do the trick for sockets.

> Please tell me who I need to report this to to get it fixed.

The latest Linux man pages can always be found at 
ftp://ftp.win.tue.nl/pub/linux-local/manpages/ and the maintainer is 
Andries Brouwer (Andries.Brouwer@cwi.nl) -- he'll take suitable new man 
pages, or patches in "diff -u" format.

> Also, if there is a way to get the length of the next incoming datagram,
> I would love to know about it. 

FIONREAD on a datagram socket will do this.

> Currently I'm resorting to:
> 
> while(1){
>  	recvmsg(..., MSG_PEEK);
>  	if ( flags & MSG_TRUNC ){
>  		double buffer size;
>  	} else {
>  		break;
>  	}
> }

Cheers,

Michael

-- 
Michael Kerrisk
mtk-lists@gmx.net
