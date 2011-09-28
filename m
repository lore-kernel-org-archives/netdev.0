From: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Draft manpage for recvmmsg [RESEND]
Date: Wed, 28 Sep 2011 19:29:00 +0200
Message-ID: <CAKgNAki0bw4ezSNAYMcg92Gyan049Pg7PyXkcEwJLSiAXOZ_Rg@mail.gmail.com>
Reply-To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Stephan Mueller <stephan.mueller-fwYZOkdEjagAvxtiuMwx3w@public.gmane.org>,
	Anton Blanchard <anton-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>, acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Andi, Arnaldo,

Could you please review the revised recvmmsg.2 man page below.

Andi: I need to know what copyright and license to attach to the page
before I can release it.

Thanks,

Michael

---------- Forwarded message ----------
=46rom: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Thu, Sep 15, 2011 at 6:15 AM
Subject: Re: Draft manpage for recvmmsg
To: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>
Cc: linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Stephan Mueller <stephan.mueller-fwYZOkdEjagAvxtiuMwx3w@public.gmane.org>, Anton
Blanchard <anton-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>


[CC list expanded]

Hi Andi, (and Arnaldo)

As noted in an earlier mail, I still need to know what copyright and
license to attach to the page before I can release it.

See below for further comments.

On Tue, Nov 23, 2010 at 11:15 AM, Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org> wrot=
e:
>
> Here's a draft manpage for recvmmsg(2), which is one
> of the last undocumented syscalls currently.
> Please review and comment.
>
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

I reworked a number of pieces of text, and added several other pieces.
Could you please take a look (for others interested: "man -l <file>")
at the version below and let me know of inaccuracies

Thanks,

Michael

=2ETH RECVMMSG 2 2011-09-09 "Linux" "Linux Programmer's Manual"
=2ESH NAME
recvmmsg \- receive multiple messages on a socket
=2ESH SYNOPSIS
=2Enf
=2EB "#define _GNU_SOURCE"
=2EBI "#include <sys/socket.h>"

=2EBI "int recvmmsg(int " sockfd ", struct mmsghdr *" msgvec \
", unsigned int " vlen ","
=2Ebr
=2EBI " =A0 =A0 =A0 =A0 =A0 =A0 unsigned int " flags ", struct timespec=
 *" timeout ");"
=2Efi
=2ESH DESCRIPTION
The
=2EBR recvmmsg ()
system call is an extension of
=2EBR recvmsg (2)
that allows the caller to receive multiple messages from a socket
using a single system call.
(This has performance benefits for some applications.)
A further extension over
=2EBR recvmsg (2)
is support for a timeout on the receive operation.

The
=2EI sockfd
argument is the file descriptor of the socket to receive data from.

The
=2EI msgvec
argument is a pointer to an array of
=2EI mmsghdr
structures.
The size of this array is specified in
=2EIR vlen .

The
=2EI mmsghdr
structure is defined in
=2EI <sys/socket.h>
as:

=2Ein +4n
=2Enf
struct mmsghdr {
=A0 =A0struct msghdr msg_hdr; =A0/* Message header */
=A0 =A0unsigned int =A0msg_len; =A0/* Number of received bytes for head=
er */
};
=2Efi
=2Ein
=2EPP
The
=2EI msg_hdr
field is a
=2EI msghdr
structure, as described in
=2EBR recvmsg (2).
The
=2EI msg_len
field is the number of bytes returned for the message in the entry.
This field has the same value as the return value of a single
=2EBR recvmsg (2)
on the header.

The
=2EI flags
argument contains flags ORed together.
The flags are the same as documented for
=2EBR recvmsg (2),
with the following addition:
=2ETP
=2EB MSG_WAITFORONE
Turns on
=2EB MSG_DONTWAIT
after the first message has been received.
=2EPP
The
=2EI timeout
argument points to a
=2EI struct timespec
(see
=2EBR clock_gettime (2))
defining a timeout (seconds plus nanoseconds) for the receive operation=
=2E
If
=2EI timeout
is
=2EI NULL
then the operation blocks indefinitely.

A blocking
=2EBR recvmmsg ()
call blocks until
=2EI vlen
messages have been received
or until the timeout expires.
A nonblocking call reads as many messages as are available
(up to the limit specified by
=2EIR vlen )
and returns immediately.

On return from
=2EBR recvmmsg (),
successive elements of
=2EIR msgvec
are updated to contain information about each received message:
=2EI msg_len
contains the size of the received message;
the subfields of
=2EI msg_hdr
are updated as described in
=2EBR recvmsg (2).
The return value of the call indicates the number of elements of
=2EI msgvec
that have been updated.
=2ESH RETURN VALUE
On success,
=2EBR recvmmsg ()
returns the number of messages received in
=2EIR msgvec ;
on error, \-1 is returned, and
=2EI errno
is set to indicate the error.
=2ESH ERRORS
Errors are as for
=2EBR recvmsg (2).
In addition, the following error can occur:
=2ETP
=2EB EINVAL
=2EI timeout
is invalid.
=2ESH VERSIONS
The
=2EBR recvmmsg ()
system call was added in Linux 2.6.32.
Support in glibc was added in version 2.12.
=2ESH CONFORMING TO
=2EBR recvmmsg ()
is Linux-specific.
=2ESH SEE ALSO
=2EBR clock_gettime (2),
=2EBR recvmsg (2),
=2EBR sendmmsg (2),
=2EBR sendmsg (2),
=2EBR socket (2),
=2EBR socket (7)

--
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface"; http://man7.org/tlpi/



--=20
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface"; http://man7.org/tlpi/
