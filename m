From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] linux 2.9.10-rc1: Fix oops in unix_dgram_sendmsg when
	using SELinux and SOCK_SEQPACKET
Date: Thu, 18 Nov 2004 16:45:14 +0000
Message-ID: <1100796294.6019.8.camel@localhost.localdomain>
References: <Xine.LNX.4.44.0411172222160.2531-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ross Kendall Axe <ross.axe@blueyonder.co.uk>, netdev@oss.sgi.com,
        Stephen Smalley <sds@epoch.ncsc.mil>,
        lkml <linux-kernel@vger.kernel.org>, Chris Wright <chrisw@osdl.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0411172222160.2531-100000@thoron.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Iau, 2004-11-18 at 03:42, James Morris wrote:
> > Well, my reading of socket(2) suggests that it's _not_ supposed to work.
> 
> sendto() on a non connected socket should fail with ENOTCONN.

Not entirely true at all. A network protocol can implement lazy binding
and
do implicit binding on the sendto. Other protocols might not actually
have
a receiving component so have no bind() functionality at all.

> According to the send(2) man page, we may return EISCONN if the address
> and addr length are not NULL and zero.  I think that the man page is
> incorrect.  Posix says that EISCONN means "A destination address was
> specified and the socket is already connected", not "A destination address
> was specified and the socket is connected mode".  i.e. we should only 
> return EISCONN if the socket is in a connected state.

POSIX 1003.1g draft 6.4 permits a user to pass a "null" address for
various things. Indeed some systems implement send() as sendto() with a
NULL, 0 address component and some user space does likewise. It also has
a lot to say on the other cases although I don't think it ever fully got
past draft state.

You also want to look at TCP/IP illustrated to see some of the
assumptions handed down from on high by BSD and which should not be
broken.
