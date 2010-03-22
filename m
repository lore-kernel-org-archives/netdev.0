From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: Add PGM protocol support to the IP stack
Date: Mon, 22 Mar 2010 09:20:42 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1003220916170.15360@router.home>
References: <alpine.DEB.2.00.1003181245050.23010@router.home> <87tysccjrn.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87tysccjrn.fsf@basil.nowhere.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 19 Mar 2010, Andi Kleen wrote:

> Christoph Lameter <cl@linux-foundation.org> writes:
> >
> > I know about the openpgm implementation. Openpbm does this at the user
> > level and requires linking to a library. It is essentially a communication
> > protocol done in user space. It has privilege issues because it has to
> > create PGM packets via a raw socket.
>
> That seems like a poor reason alone to put something into the kernel
> Perhaps you rather need some way to have unpriviledged raw sockets?

Not the only reason. There are also performance implications. NAKing and
other control messages from user space are a pain and the available
implementations add numerous threads just to control the timing of control
messages and the expiration of data etc. Its difficult to listen to a PGM
port from user space. You have to get all messages for the PGM protocol
and then filter in each process.

PGM operates on the same level as TCP and UDP.

> The classical way to do this is to start suid root, only open
> the socket and then drop privileges.

Yes those solutions exist and the experience with their limitations are
the reason to try to get PGM in the kernel.
