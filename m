From: "David S. Miller" <davem@davemloft.net>
Subject: Re: udp_recvmsg: possible bug causing infinite hang?
Date: Sat, 9 Oct 2004 18:45:03 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20041009184503.7fc5c105.davem@davemloft.net>
References: <Pine.LNX.4.44.0303270917290.29072-100000@home.transmeta.com>
	<Pine.GSO.4.44.0410091824350.14026-100000@falcon.csc.calpoly.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "Chad N. Tindel" <ctindel@falcon.csc.calpoly.edu>
In-Reply-To: <Pine.GSO.4.44.0410091824350.14026-100000@falcon.csc.calpoly.edu>
List-Id: netdev.vger.kernel.org

On Sat, 9 Oct 2004 18:38:58 -0700 (PDT)
"Chad N. Tindel" <ctindel@falcon.csc.calpoly.edu> wrote:

> User space code sends a datagram on a blocking socket, and then calls
> select() or poll() to wait for the reply.

If you wish the socket not to block, mark the file descriptor
as non-blocking or pass in the appropriate MSG_* flag into
recvmsg().

Select() returning that a filedescriptor is readable does not
guarentee that a blocking socket will not block in the ead
call.

This behavior has been in the Linux kernel for an enourmous
amount of them, the change you are noticing going from EL 3 update
2 to update 3 is that previously we were returning -EAGAIN to
blocking sockets, instead we are properly blocking to wait for
another packet.

There is an enormous and long thread about this topic on the
linux-kernel list, please read there before we duplicate such
a long and tiring thread here.
