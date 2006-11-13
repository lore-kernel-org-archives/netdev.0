From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Questions regarding network drivers
Date: Mon, 13 Nov 2006 12:05:32 +0300
Message-ID: <20061113090532.GA20664@2ka.mipt.ru>
References: <20061111115449.GA22586@2ka.mipt.ru> <454688.85582.qm@web31512.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:27800 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1753159AbWKMJFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Nov 2006 04:05:31 -0500
To: Jonathan Day <imipak@yahoo.com>
Content-Disposition: inline
In-Reply-To: <454688.85582.qm@web31512.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 11, 2006 at 03:21:17PM -0800, Jonathan Day (imipak@yahoo.com) wrote:
> 
> --- Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> > You can use netchannels, which were designed for
> > exactly that kind of
> > load.
> 
> Actually, netchannels are a mechanism I've been
> looking at intensely, as a way to simplify this and
> keep it sane, without loosing performance.
> 
> > You need to process some headers anyway - to select
> > appropriate socket
> > or netchannel or whatever.
> 
> I was planning on cheating there. I've revised the
> method slightly, based on previous comments, so that
> I'm now doing the following:
> 
> The master table has a set of pointers to tables. One
> group, one table - for groups in use. Unused groups
> have no associated table and the pointer is null.
> Pointers are always at (group number * pointer size)
> from the start of the table. There's a max of 4096
> groups in this system, or the hardware guys start
> shooting.
> 
> Each group has a table that contains a set of pointers
> to buffers. Offset is always (node number * pointer
> size). Nodes that are active members have pointers to
> pinned, allocated and cleaned buffers. Nodes that
> aren't members get null pointers. There are 32 nodes
> in the current system.
> 
> The packet header contains the group address at a
> fixed offset and the source node number at another
> fixed offset. The hardware can then grab these and do
> the necessary calculations. The hardware has a DMA
> controller which can get the group pointer from the
> master table then get the buffer pointer from the
> group table.
> 
> (Essentially, I'm mimicking a primitive virtual memory
> system here.)

Do you have any benchmarks of that system, it looks quite complex to
avoid some problems...

> The hardware then stores enough packet payloads to
> fill one page of memory (unless it gets an
> end-of-transmit signal before then) and then DMAs the
> page of data into the physical page in one shot.
> (Since I did the original design, I worked out that
> there's too much overhead in setting up a transmit to
> just do a single packet at a time.) The hardware is
> apparently smart enough to re-order packers if they
> come in out of sequence and to NACK anything that's
> missing.

I.e. it supports TCP sequence number checks?
In that case you store a set of flows in hardware, what happens when it
overflows?

> Once a page has been filled, the driver simply pushes
> the pointer onto a queue and then grabs a pointer to a
> fresh page.
> 
> 
> Based on what I'm hearing, I'll probably finish this
> driver simply to see what it does and post it up -
> it'll have educational value, whatever happens. I'll
> also work on a netchannels version which is less
> hardware-specific and more "normal".

That would be great.

> > > I can try getting beer. Oregon has some acceptable
> > > microbreweries, but I miss having a pint of
> > Hatters in
> > > England. Mead is easier. I brew mead. Strong, dry,
> > > rocket-fuel mead.
> > 
> > Then you definitely just need to send your driver to
> > netdev@.
> 
> Sounds good to me. Liquid driver review aids will be prepared.
 
That's good - send your dirver and some kind of benchmarks for
throughput and latency tests. 
  

-- 
	Evgeniy Polyakov
