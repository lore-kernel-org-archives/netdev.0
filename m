From: Alexey Toptygin <alexeyt@freeshell.org>
Subject: Re: kernel-manpage inconsistency
Date: Thu, 15 Jul 2004 13:45:40 +0000 (UTC)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.NEB.4.60.0407151335140.18100@mx.freeshell.org>
References: <Pine.NEB.4.60.0407142202270.24397@ukato.freeshell.org>
 <4407.1089895895@www4.gmx.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael T Kerrisk <mtk-lists@gmx.net>
In-Reply-To: <4407.1089895895@www4.gmx.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 15 Jul 2004, Michael T Kerrisk wrote:

>> In recv(2) it says:
>>
>>      MSG_TRUNC
>>  	Return  the  real  length of the packet, even when it was longer
>>  	than the passed buffer. Only valid for packet sockets.
>>
>> But this is not honored.
>
> I don't know the details here, sorry.  A quick glance at the source
> (raw_recvmsg() in net/ipv4/raw.c) shows that MSG_TRUNC is used there.

Yes, it's used, but like this:

         copied = skb->len;
         if (len < copied) {
                 msg->msg_flags |= MSG_TRUNC;
                 copied = len;
         }

that is to say, MSG_TRUNC is set in the struct msghdr that you get back 
from the recvmsg call, but the length you get out is still <= what you 
passed in. This is not what the manpage is implying. Nearly identical code 
is in udp.c, in af_unix.c, etc. I guess my question is should this be 
changed in the kernel or in the manpage?

>> Also, in udp(7), it says:
>>
>> IOCTLS
>>      These ioctls can be accessed using ioctl(2).  The correct syntax is:
>>
>>  	int value;
>>  	error = ioctl(tcp_socket, ioctl_type, &value);
>>
>>      SIOCINQ
>>  	Gets a pointer to an integer as argument. Returns  the  size  of
>>  	the  next pending datagram in the integer in bytes, or 0 when no
>>  	datagram is pending.
>>
>>      SIOCOUTQ
>>  	Returns the number of data bytes in the local send  queue.  Only
>>  	supported with Linux 2.4 and above.
>>
>> These don't appear to be implemented. ( They're not in any headers and
>> they're not listed in ioctl_list(2). )
>
> They're names in the kernel source.  In userland, FIONREAD and TIOCOUTQ will
> do the trick for sockets.

You're right! Here it is in include/linux/sockios.h:

/* Linux-specific socket ioctls */
#define SIOCINQ         FIONREAD
#define SIOCOUTQ        TIOCOUTQ

But why would the man page document the kernel-specific names, and not the 
ones you can see in libc?

>> Please tell me who I need to report this to to get it fixed.
>
> The latest Linux man pages can always be found at
> ftp://ftp.win.tue.nl/pub/linux-local/manpages/ and the maintainer is
> Andries Brouwer (Andries.Brouwer@cwi.nl) -- he'll take suitable new man
> pages, or patches in "diff -u" format.

Thanks.

 			Alexey
