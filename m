From: Jonathan Day <imipak@yahoo.com>
Subject: Re: Scheduler Mechnisms!
Date: Tue, 4 Jan 2005 19:59:46 -0800 (PST)
Message-ID: <20050105035946.38738.qmail@web12303.mail.yahoo.com>
References: <304889647.25037@njupt.edu.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lartc@mailman.ds9a.nl
Return-path: <lartc-admin@mailman.ds9a.nl>
To: Zhenyu Wu <y030729@njupt.edu.cn>, netdev@oss.sgi.com
In-Reply-To: <304889647.25037@njupt.edu.cn>
Sender: lartc-admin@mailman.ds9a.nl
Errors-To: lartc-admin@mailman.ds9a.nl
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Subscribe: <http://mailman.ds9a.nl/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
List-Unsubscribe: <http://mailman.ds9a.nl/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc/>
List-Id: netdev.vger.kernel.org

I may be wrong on this, but I believe that RED can be
attached to any queueing system, including the basic
FIFO queues. In a sense, you're still using a
scheduling system, when using the default arrangement,
it's just a first-come, first-served one.

RED is classless and applies to the whole of a queue.
What that queue is attached to, if I understand it
correctly, isn't important. It can be a class, but it
can just as easily be everything going through that
device.

Again, someone correct me if I'm wrong, but as I
understand it, there are four levels to the whole
QoS/diffserv concept.

One of these levels is the queueing discipline. This
can be something like CBQ, WFQ, FIFO, PRIO, or
whatever. This is how the data is organized, it does
not describe how the data is sent. In the case of
something like CBQ, you have a defined set of queues
in parallel, with rules as to what packets fall into
what queue. On the other hand, queueing schemes such
as FIFO are flat. There's a single queue that
everything goes through, though there may be different
rules for how things get pushed to it.

Another level is the scheduling mechanism. This
describes how the data is sent, once organized, but
does not describe the organization itself. If you've
only one queue, then there's really not much to
schedule. If you've multiple queues, then it's fairly
normal to use "round robin" or "weighted round robin"
to pick which queue to pull a packet from. Linux' CBQ
uses "weighted round robin", according to the C file.

The next level is the packet dropping mechanism. When
queues flood, packets are going to be dropped. There's
nowhere to store them. I'm pretty sure the default
behaviour is to simply continue accepting packets, but
to drop any that expire before being sent or which
fall off the end of the queue (if the queue is
bounded). RED, GRED, and a whole host of similar
mechanisms, try to drop packets in a more controlled
manner. However, that is really all they do.

Finally, there are mechanisms for damping overly
active applications, such as ECN. The idea here is
that if you throttle back whatever is generating
excess traffic, you don't get the problems assoicated
with dealing with it. The "default" behaviour is to do
nothing.

When setting up QoS - on Linux or anything else - you
basically pick one of each of the four categories to
assemble a packet delivery system. Even without QoS,
you're doing that, you're just using the defaults in
all cases. The mechanisms are still going to be there.

The Linux configuration menu does NOT match the above
terminology, or the terminology in the source code.
Thus, the source code identifies CBQ as a queueing
discipline, but the configuration menu calls it a
scheduler. The QoS help is also not very helpful, as
it mostly tells people to look at the source. However,
if you look at the source for CBQ or RED, for example,
the explanation is relative to the cited papers, so
you then have to go and read those before coming back
and doing anything.

This is one area I hope is going to get resolved in
the reasonably near future. If not, I might have to
come up with a patch myself. The very thought of that
should send shivers down the spines of any kernel
developers out there.

Jonathan

--- Zhenyu Wu <y030729@njupt.edu.cn> wrote:

> Thank you very much, i will try to find these papers
> which must be very helpful
> for me. The "more" means that whether there are
> other mechanisms not only for
> Linux. Sorry, i have not make it clear! Sometimes, i
> wonder whether the qdiscs
> such as CBQ, RED, GRED ... are belong to the
> scheduler mechanisms in linux
> enviroment. For example, In Red, which i can find
> are enqueue, and dequeue.... so,
> if i add a RED qidsc to a class, must i add a
> scheduler mechanism so that i can
> decide which packet in the queues will be scheduled
> and put to the link?
> 
> Good luck,
> Best,



		
__________________________________ 
Do you Yahoo!? 
The all-new My Yahoo! - What will yours do?
http://my.yahoo.com 
_______________________________________________
LARTC mailing list / LARTC@mailman.ds9a.nl
http://mailman.ds9a.nl/mailman/listinfo/lartc HOWTO: http://lartc.org/
