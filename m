From: kuznet@ms2.inr.ac.ru
Subject: Re: PATCH Re: udp weirdness
Date: Tue, 1 Oct 2002 19:31:37 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200210011531.TAA19943@sex.inr.ac.ru>
References: <3D99B6C7.3010302@nortelnetworks.com>
Mime-Version: 1.0
Cc: hadi@cyberus.CA, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: cfriesen@nortelnetworks.com (Chris Friesen)
In-Reply-To: <3D99B6C7.3010302@nortelnetworks.com> from "Chris Friesen" at Oct 1, 2 10:52:55 am
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> > Feel free to implement. :-)
> 
> I may have to poke around...if nothing else I'll learn more about the 
> networking code...

It is difficult task, if possible at all.

The main obstacle is that we must not block after select() succeeded,
otherwise applications will lockup. Taking into account nature of datagram
services (and generally of networking services, where routes change et al.)
you do not know at time of select(), where the datagram will go.
So, blocking can be made only based on a criterium not depending on this.

We use sndbuf (like all the OSes). Actually, the problem with silent
losses is solved by tuning SO_SNDBUF. Though it is not a complete
solution (failing whith lots of senders), it solves all those bullshit
problems with silent losses. People just do not care about this, so
they get the thing which they deserve.


> dropped when there is congestion.  If IP_RECVERR is turned on, would 
> sendto() then return -1 so I know to try and read the error messages? 

Yes.


> I'm assuming I get ENOBUFS back in the ee_code field?  Or can I get away 
> with reading errno and ignoring the error queue?

No, error queue should be read. But not all the errors are queued,
only those which are supported asynchronously. ENOBUFS is still not.
F.e. when packet is dropped lately (some qdiscs do this, dropping already
queued packets to give place for another ones) ENOBUFS is not sent back.


>			     there doesn't seem to be a lot of 
> documentation about it.

Damn! (I'm sorry) It is documented _very_ well, thanks to Andi.
I really hate this mode when people do not worrying even to look to manpages
before pronouncing such statements.

man recvmsg
man ip

Alexey
