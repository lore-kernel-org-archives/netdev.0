From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Questions wrt QoS code on Linux
Date: Fri, 13 May 2005 01:32:35 +0200
Message-ID: <20050512233235.GJ28419@postel.suug.ch>
References: <20050512190721.17518.qmail@web31508.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jonathan Day <imipak@yahoo.com>
Content-Disposition: inline
In-Reply-To: <20050512190721.17518.qmail@web31508.mail.mud.yahoo.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Jonathan Day <20050512190721.17518.qmail@web31508.mail.mud.yahoo.com> 2005-05-12 12:07
> You've actually got another bit in there which
> determines the ordering of the packets. a FIFO queue
> won't be ordered the same as a PRIO queue, for
> example.

I don't see the point why we should draw a line between
something like PRIO and CBQ, I would agree that dsmark
should be splitted though.

> A completely seperate stage is then needed to actually
> gather the packets from the queue(s). You might drain
> one queue completely before moving onto the next, you
> might work in a round-robin manner, you might even
> give a queue a fixed timeslice and grab as many
> packets as possible within that slice before moving
> on.

a) The qdisc _must_ be able to define the ordering, otherwise
   we cannot do rate limiting correctly.

b) You definitely don't want reordering inside flows and the
   qdisc is the only player that is aware of the right ordering.
      
> An additional section handles the case where the
> network is overloaded. You can drop packets early, by
> using systems like RED, BLUE, GREEN or BLACK. (Of
> these, only RED and the variant GRED are in Linux at
> the moment.)

The current RED implementation uses a queue and its length
as criteria for the congestion probability. However, I do
agree that in theory this should be implemented differently,
the detection and marking should take place before the
queue possibly via actions. This would also easly allow for
(colored) TSW and EWMA rate estimators to be put in front.

Surely everyone can agree that there is potential in this
area and I hope someone brave stands up one day doing all
the work.

> At present, the Linux QoS menu is confusing. CBQ is
> listed as a packet scheduler, when it in fact queues
> the packets, rather than schedules them. RED is marked
> as a queue, whereas it really filters, it doesn't
> queue.

The menu really can be improved and I think such a patch
would get accepted, although please leave the qdiscs
alone for now. ;->

> 1. Rename the sched directory to qos

I don't see any improvement comming along with
change as well.

> 2. Add a sched subdirectory and move the schedulers
> into it
> 3. Add a queue subdirectory and move the queue
> handlers into it
> 4. Add a classifier subdirectory and move the packet
> classifiers into it
> 5. Add a processor subdirectory and move all code for
> processing packets (such as RED) into it

I think the (sch_|cls_|em_) prefixes are just fine
for now.
