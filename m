From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: Re: RFC: per-socket statistics on received/dropped packets
Date: Mon, 10 Jun 2002 15:28:14 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <aech7u$31k$2@main.gmane.org>
References: <Pine.GSO.4.30.0206101033450.22559-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: linux-kernel@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> 
> On Mon, 10 Jun 2002, Mark Mielke wrote:

> > There *are* applications that would benefit from making this decision
> > at run time on a socket-by-socket basis. It is not a common requirement
> > for most desktop users, but it remains a valid requirement.
> >
> 
> I am confused as to which application needs this, do you have one in mind?
> AFAIK, UDP/RTP type apps already know how to determine packet loss
> on a per flow basis.


The purpose of this patch is to make it reallly easy to nail down exactly how
many packets were dropped *per socket*, and for what reason.  For me, the
information is then used to tune the application statically, but others could
use it dynamically.  Incoming packets can be dropped at the device, at the
device driver, in netif_rx, or at the socket buffer.  We've got stats on all of
these except for the socket buffer, so why not add them?

The cost in the normal case is incrementing a single variable in the socket
struct (which is likely already in cache since we're playing with it).  I can't
see this being that expensive.  In the failure path, we get a second increment. 
Again, this is not going to be noticeable.

Sure, you can try and figure out which applications had sockets open, and how
many packets they missed, and subtract that from the snmp counters to give how
many packets you missed.  But to do this you have to lock the box down--isn't it
a lot easier to just *know* because you've been keeping track?

Chris

-- 
Chris Friesen                    | MailStop: 043/33/F10  
Nortel Networks                  | work: (613) 765-0557
3500 Carling Avenue              | fax:  (613) 765-2986
Nepean, ON K2H 8E9 Canada        | email: cfriesen@nortelnetworks.com
