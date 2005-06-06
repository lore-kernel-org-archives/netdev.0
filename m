From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [Linux Diffserv] GRED queueing discipline and the file sch_gred.c
Date: Mon, 6 Jun 2005 13:39:07 +0200
Message-ID: <20050606113907.GC15391@postel.suug.ch>
References: <20050605221106.GB15391@postel.suug.ch> <BAY24-F263AE581155F279A048AE6C5FB0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: diffserv-general@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: rahul hari <rahulhsaxena@hotmail.com>
Content-Disposition: inline
In-Reply-To: <BAY24-F263AE581155F279A048AE6C5FB0@phx.gbl>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rahul,

* rahul hari <BAY24-F263AE581155F279A048AE6C5FB0@phx.gbl> 2005-06-06 16:08
> Thanks for the reply. Actually in my experiment, I am implementing 2 
> queues, in one of the queues, I use the prio scheme of tc and in another I 
> define 3 virtual queues, out of which I want to provide absolute priority 
> to one of the queue over the others (ie, if there is any packet in this 
> queue, it should be dispatched immediately regardless of whatever happens 
> to the other two virtual queues).

Use a prio qdisc with RED leaf qdiscs. RED and GREDs purpose is to
calculate a marking probability and not to provide any prioritizing
schemes. RIO mode is a small exception from this but the used priority
only describes the weight of the VQ and has no influence on the actual
queue position later on.

> For the other two virtual queues, I want to apply individual REDs (with 
> different parameters but the average queue length should be equal to the 
> total qave of these two virtual queues) on each but the dequeuing priority 
> should be equal (the dequeuing takes place alternately).

Use a GRED qdisc, give both VQs the same prio (so they go into equalize
mode) and enable RIO mode. The VQ you select as default will be used to
store qavg and the idle time.



                      CBQ
    cbq:queue_1            cbq:queue_2
        |                       |
       prio                   GRED (rio mode)
   |     |     |          |            |
 RED_1 RED_2 RED_3   VQ1(prio=1)  VQ2(prio=1)

You did not talk about how to separate the two initial queues so I
assumed CBQ but it doesn't really matter as long its a classful qdisc.
