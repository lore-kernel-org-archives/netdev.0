From: =?iso-8859-1?q?an7?= <an3h0ny@yahoo.fr>
Subject: tcp checksumming
Date: Tue, 4 Nov 2003 14:32:40 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031104133240.89887.qmail@web11105.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

In tcp_rcv_established(), when you are in fast path,
you use checksum and copy (the first function in the
chain is tcp_copy_to_iovec) to finally delivering data
to the user.

I browse datagram.c,checksum.h,skbuff.c,tcp_input.c
and only sees (mainly by following function calls in
datagram.c) checksum calculation, by a lot of calls to
csum_fold() and csum_partial(), and copy to iovec, but
i have never seen the checksum _verification_.

I learn that skb->csum is (when you have not CHECKSUM
UNECESSARY defined in the case of a device computing
the checksum by itself) the checksum on running
data.But it is used in all functions,and get replaced
by a function result. I don't see where it is used as
a comparison

My question is pretty simple : where in the code, is
the tcp checksum verified (compared to the computed
one). My first impression was that it was done in the
*copy_and_csum* functions, but i only see checksum
computation.

That is to say, it is like a side effect of keeping
data in a buffer with a bad checksum.(maybe it is
removed after ? i don't think so)

PS : i have posted here many times, never get an
answer. Please pay a little attention=20


___________________________________________________________
Do You Yahoo!? -- Une adresse @yahoo.fr gratuite et en fran=E7ais !
Yahoo! Mail : http://fr.mail.yahoo.com
