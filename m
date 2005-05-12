From: Jonathan Day <imipak@yahoo.com>
Subject: Re: Questions wrt QoS code on Linux
Date: Thu, 12 May 2005 12:07:21 -0700 (PDT)
Message-ID: <20050512190721.17518.qmail@web31508.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: 6667
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I'll deal with the first part first, as it's the
easiest. :)

Very crudely, you can look at networking as being
carried out in two stages - collecing the packets to
be sent, and then sending them.

Something like CBQ tells the machine how to go about
collecting the packets, by creating a number of queues
into which the packets can be placed.

A distinct section of code for classifying packets is
used to help the collector to identify the different
types of packet so that the collector can handle them
correctly.

You've actually got another bit in there which
determines the ordering of the packets. a FIFO queue
won't be ordered the same as a PRIO queue, for
example.

A completely seperate stage is then needed to actually
gather the packets from the queue(s). You might drain
one queue completely before moving onto the next, you
might work in a round-robin manner, you might even
give a queue a fixed timeslice and grab as many
packets as possible within that slice before moving
on.

An additional section handles the case where the
network is overloaded. You can drop packets early, by
using systems like RED, BLUE, GREEN or BLACK. (Of
these, only RED and the variant GRED are in Linux at
the moment.)

At present, the Linux QoS menu is confusing. CBQ is
listed as a packet scheduler, when it in fact queues
the packets, rather than schedules them. RED is marked
as a queue, whereas it really filters, it doesn't
queue.

My proposal is to do the following:

1. Rename the sched directory to qos
2. Add a sched subdirectory and move the schedulers
into it
3. Add a queue subdirectory and move the queue
handlers into it
4. Add a classifier subdirectory and move the packet
classifiers into it
5. Add a processor subdirectory and move all code for
processing packets (such as RED) into it

Everything else would be left where it was. Help files
and menu syntax would be changed to reflect what the
option actually did. I would probably want to change
the symbols as well, to make it easier to follow in
the code as to what is happening.

--- Thomas Graf <tgraf@suug.ch> wrote:
> * Jonathan Day
>
<20050512044040.61360.qmail@web31504.mail.mud.yahoo.com>
> 2005-05-11 21:40
> > First off, I notice that all the code is lumped
> > together and much of it is generically labelled
> > "scheduling". I'm wondering if it might not be
> more
> > readable if the list were divided into four
> sections -
> > "queueing disciplines", "scheduling", "packet
> > classification" and "everything else". Would that
> seem
> > sensible? Or would it risk making things
> > over-structured?
> 
> Sounds reasonable although I'm not sure if I
> understand
> the difference between "scheduling" and "qdisc".



		
__________________________________ 
Yahoo! Mail Mobile 
Take Yahoo! Mail with you! Check email on your mobile phone. 
http://mobile.yahoo.com/learn/mail 
