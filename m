From: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Draft manpage for recvmmsg
Date: Fri, 9 Sep 2011 22:52:43 +0200
Message-ID: <CAKgNAkh6upg2r+tntmEJt-Kh2H91xWqqmaiGjdo785LtBTGwWA@mail.gmail.com>
References: <20101123101551.GA20431@basil.fritz.box>
Reply-To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20101123101551.GA20431-u0/ZJuX+froe6aEkudXLsA@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Andi,

On Tue, Nov 23, 2010 at 11:15 AM, Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org> wrot=
e:
>
> Here's a draft manpage for recvmmsg(2), which is one
> of the last undocumented syscalls currently.
> Please review and comment.

Thanks for this page. Can you tell me what license and copyright
should be assigned to it?
See http://man7.org/linux/man-pages/licenses.html

Thanks,

Michael

> -Andi
>
>
> .TH RECVMMSG 2 2010-11-23 "Linux" "Linux Programmer's Manual"
> .SH NAME
> recvmmsg \- receive multiple messages on a socket
> .SH SYNOPSIS
> .BI "#include <sys/socket.h>"
> .br
> .BI "int recvmmsg(int " fd ", struct mmsghdr *" mmsghdr \
> ", unsigned int " vlen ","
> .br
> .BI " =A0 =A0 =A0 =A0 =A0 =A0 unsigned int " flags ", struct timespec=
 *" timeout ");"
> .SH DESCRIPTION
> The
> .B recvmmsg
> system call receives multiple messages in a socket.
> It acts similar to
> .B recvmsg(2),
> but allows to batch multiple receive operations into a single syscall=
=2E
> In addition it support an explicit timeout.
>
> .B fd
> is the file descriptor of the socket to receive data from.
> .B mmsghdr
> is a pointer to an array with length
> .B vlen
> of
> .I mmsghdr
> structures.
> .I struct mmsg
> is defined in
> .I sys/socket.h
> as:
> .in +4n
> .nf
> struct mmsghdr {
> =A0 =A0struct msghdr msg_hdr; =A0/* Message header */
> =A0 =A0unsigned int =A0msg_len; =A0/* Number of received bytes for he=
ader */
> };
> .fi
> .in
> .PP
> .B msg_hdr
> is a struct
> .I msghdr
> as described in
> .I recvmsg(2).
> .B msg_len
> is the number of bytes returned for the message in the entry.
> This field has the same value as the return value of a single
> .I recvmsg(2)
> on the header.
>
> .B flags
> contains flags ored together. The flags are the same
> as documented for
> .I recvmsg(2).
> The additional
> .B MSG_WAITFORONE
> turns one
> .I MSG_DONTWAIT
> after the first message has been received.
>
> .B timeout
> points to a
> .I struct timespec
> (see
> .I clock_gettime(2)
> )
> defining a timeout for receiving, or
> .I NULL
> for no timeout. When the timeout expires
> .I recvmmsg
> returns.
> .SH RETURN VALUE
> .I recvmmsg
> returns the number of messages received in
> .I mmsghdr
> or
> -1
> when an error occurs. The
> .I msg_len
> members of
> .I mmsghdr
> are updated for each received message,
> in addition to other fields in the msg_hdr for each message,
> as described in
> .I recvmsg(2).
> .SH SEE ALSO
> .B recvmsg(2),
> .B sendmsg(2),
> .B socket(7),
> .B socket(2),
> .B clock_gettime(2)
> .SH VERSIONS
> The
> .I recvmmsg
> syscall was added with kernel 2.6.32.
> Support in glibc was added with 2.6.12.
> On earlier glibcs the function can be called
> manually using
> .I syscall(2).
>
>
> --
> ak-VuQAYsv1563Yd54FQh9/CA@public.gmane.org -- Speaking for myself only.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-man" =
in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>



--=20
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface"; http://man7.org/tlpi/
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
