From: "Chad N. Tindel" <chad@tindel.net>
Subject: Re: udp_recvmsg: possible bug causing infinite hang?
Date: Sat, 9 Oct 2004 21:54:32 -0400
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20041010015432.GA38395@calma.pair.com>
References: <Pine.LNX.4.44.0303270917290.29072-100000@home.transmeta.com> <Pine.GSO.4.44.0410091824350.14026-100000@falcon.csc.calpoly.edu> <20041009184503.7fc5c105.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041009184503.7fc5c105.davem@davemloft.net>
List-Id: netdev.vger.kernel.org

On Sat, Oct 09, 2004 at 06:45:03PM -0700, David S. Miller wrote:
> On Sat, 9 Oct 2004 18:38:58 -0700 (PDT)
> "Chad N. Tindel" <ctindel@falcon.csc.calpoly.edu> wrote:
> 
> > User space code sends a datagram on a blocking socket, and then calls
> > select() or poll() to wait for the reply.
> 
> If you wish the socket not to block, mark the file descriptor
> as non-blocking or pass in the appropriate MSG_* flag into
> recvmsg().
> 
> Select() returning that a filedescriptor is readable does not
> guarentee that a blocking socket will not block in the ead
> call.
> 
> This behavior has been in the Linux kernel for an enourmous
> amount of them, the change you are noticing going from EL 3 update
> 2 to update 3 is that previously we were returning -EAGAIN to
> blocking sockets, instead we are properly blocking to wait for
> another packet.
> 
> There is an enormous and long thread about this topic on the
> linux-kernel list, please read there before we duplicate such
> a long and tiring thread here.

OK, so what you're saying is that the C-library has a bug because it isn't 
using a non-blocking socket when doing DNS lookups?

Thanks,

Chad
