From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: Add PGM protocol support to the IP stack
Date: Mon, 22 Mar 2010 14:32:26 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1003221428320.21378@router.home>
References: <alpine.DEB.2.00.1003181245050.23010@router.home> <87tysccjrn.fsf@basil.nowhere.org> <alpine.DEB.2.00.1003220916170.15360@router.home> <20100322163609.GZ20695@one.firstfloor.org> <alpine.DEB.2.00.1003221146260.17230@router.home>
 <877hp4i76d.fsf@basil.nowhere.org> <alpine.DEB.2.00.1003221300180.17230@router.home> <20100322185310.GA20695@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100322185310.GA20695@one.firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 22 Mar 2010, Andi Kleen wrote:

> > Multiple processes would communicate via shm segments. Maybe defer to the
> > future but its an important operation mode as the systems grow bigger and bigger.
> > SHM segment would have to contain some sort of ring buffer that the
> > receivers could tap into. But that mode has not really been thought
> > through.
>
> AF_UNIX is not SHM today.
>
> The only point is to avoid one copy? (user1 -> kernel -> user2  to user1 -> user2)
> Not sure if that is really worth it. Don't you need another copy to the reliability
> buffer anyways?

Not sure either. Access of multiple processes to one reliability buffer
would be best. Some sort of multiended pipe I guess.

> But in principle AF_INET over localhost should not be that less efficient
> than AF_UNIX, so you can probably drop it for now (unless you need special AF_UNIX
> features like credentials)

Well lets skip it for now and see if there are performance implications in
the future.

> > > That's unusual to have such a option (except the MTU). What is it good for?
> >
> > No idea why it was implemented. It can be used to use send() for portions
> > of a message. Triggers the send() only when all bytes have been provided.
> > Probably necessary if one wants to have very long (megabytes) messages.
>
> Those could be a problem in kernel memory consumption. One would need
> to be very careful to have a good memory management scheme for the socket
> in place.

Lets not support it then unless someone can make a convincing case.

> > Reliable multicast protocols have a defined time period / "reliabilty
> > buffer" so that they can resend a message that was missed for a time
> > period. It is customary to either specify a time period or define the size
> > of the "reliability buffer".
>
> One problem is memory management then. What happens when a process opens 100 of those
> sockets and fills them all?

Pushes out the app? Same as the user space apps now. Some sort of
upper limit is needed I guess.

> I guess you would still need a suitable global limit like TCP has.

Yes.
