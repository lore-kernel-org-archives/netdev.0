From: James Morris <jmorris@redhat.com>
Subject: Re: [PATCH] linux 2.9.10-rc1: Fix oops in unix_dgram_sendmsg when
 using SELinux and SOCK_SEQPACKET
Date: Thu, 18 Nov 2004 13:40:35 -0500 (EST)
Message-ID: <Xine.LNX.4.44.0411181328460.5555-100000@thoron.boston.redhat.com>
References: <1100796518.6019.11.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ross Kendall Axe <ross.axe@blueyonder.co.uk>, <netdev@oss.sgi.com>,
        Stephen Smalley <sds@epoch.ncsc.mil>,
        lkml <linux-kernel@vger.kernel.org>, Chris Wright <chrisw@osdl.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1100796518.6019.11.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 18 Nov 2004, Alan Cox wrote:

> On Iau, 2004-11-18 at 08:27, James Morris wrote:
> > 2) Ensure that unix_dgram_sendmsg() fails for SOCK_SEQPACKET sockets which
> > are not connected, otherwise someone could bypass LSM by sending on an
> > unconnected socket.
> 
> What about half closed and other connected states ? This patch seems
> inadequate for things like X.25

The patch only affects the Unix code and does not change existing 
semantics for other connected states.

One thing that looks broken (unrelated to the patch I posted) is that
unix_dgram_sendmsg() already does not check sk->sk_shutdown &
SEND_SHUTDOWN for SOCK_SEQPACKET.


- James
-- 
James Morris
<jmorris@redhat.com>
