From: James Morris <jmorris@redhat.com>
Subject: Re: [PATCH] linux 2.9.10-rc1: Fix oops in unix_dgram_sendmsg when
 using SELinux and SOCK_SEQPACKET
Date: Thu, 18 Nov 2004 13:28:23 -0500 (EST)
Message-ID: <Xine.LNX.4.44.0411181324220.5555-100000@thoron.boston.redhat.com>
References: <1100796294.6019.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ross Kendall Axe <ross.axe@blueyonder.co.uk>, <netdev@oss.sgi.com>,
        Stephen Smalley <sds@epoch.ncsc.mil>,
        lkml <linux-kernel@vger.kernel.org>, Chris Wright <chrisw@osdl.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1100796294.6019.8.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 18 Nov 2004, Alan Cox wrote:

> On Iau, 2004-11-18 at 03:42, James Morris wrote:
> > > Well, my reading of socket(2) suggests that it's _not_ supposed to work.
> > 
> > sendto() on a non connected socket should fail with ENOTCONN.
> 
> Not entirely true at all. A network protocol can implement lazy binding
> and do implicit binding on the sendto. Other protocols might not
> actually have a receiving component so have no bind() functionality at
> all.

I got this from the Linux man page for sendto():

 If  sendto  is  used on a connection-mode (SOCK_STREAM, SOCK_SEQPACKET)
 socket, the parameters to and tolen are ignored (and the error  EISCONN
 may  be  returned when they are not NULL and 0), and the error ENOTCONN
 is returned when the socket was not actually connected.

And Posix 1003.1 offers the following error code for sendto():


  The sendto() function shall fail if:
  ...
  
  [ENOTCONN]
    The socket is connection-mode but is not connected.

(I'm not saying you're wrong).

> POSIX 1003.1g draft 6.4 permits a user to pass a "null" address for
> various things. Indeed some systems implement send() as sendto() with a
> NULL, 0 address component and some user space does likewise. It also has
> a lot to say on the other cases although I don't think it ever fully got
> past draft state.

sendto() with a NULL address will still work fine.


- James
-- 
James Morris
<jmorris@redhat.com>
