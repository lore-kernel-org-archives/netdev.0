From: jamal <hadi@cyberus.ca>
Subject: Re: [Linux Diffserv] GRED queueing discipline and the file
	sch_gred.c
Date: Mon, 06 Jun 2005 07:45:51 -0400
Message-ID: <1118058351.6266.119.camel@localhost.localdomain>
References: <BAY24-F263AE581155F279A048AE6C5FB0@phx.gbl>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, diffserv-general@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: rahul hari <rahulhsaxena@hotmail.com>
In-Reply-To: <BAY24-F263AE581155F279A048AE6C5FB0@phx.gbl>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-06-06 at 16:08 +0530, rahul hari wrote:
> Dear Thomas,
> Thanks for the reply. Actually in my experiment, I am implementing 2 queues, 
> in one of the queues, I use the prio scheme of tc and in another I define 3 
> virtual queues, out of which I want to provide absolute priority to one of 
> the queue over the others (ie, if there is any packet in this queue, it 
> should be dispatched immediately regardless of whatever happens to the other 
> two virtual queues).
> For the other two virtual queues, I want to apply individual REDs (with 
> different parameters but the average queue length should be equal to the 
> total qave of these two virtual queues) on each but the dequeuing priority 
> should be equal (the dequeuing takes place alternately).
> Can the current implementations somehow help me with this , or I would have 
> to design this from scratch.
> 

It is not clear what your requirements are. You are stating what your
solution is ;->
Assuming that you require to have the first queue to be of the utmost
priority followed by the first red queue as being important and then the
last two, then you need a prio qdisc with three bands:

  +---- pfifo
  |
  +---- RED
  |
  +---- GRED

The pfifo will starved the lower 2. The RED will starve the GRED if it
can and GRED virtual queues will need to be set in (CISCO) WRED mode i.e
select GRIO but give them equal priority. Make sure those two VQs have
exactly the same drop priorities and queue parameters.

cheers,
jamal
