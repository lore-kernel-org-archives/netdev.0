From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC] using mmiowb() in dev->poll() method
Date: Wed, 6 Oct 2004 12:10:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041006121031.488f33c5.davem@redhat.com>
References: <Pine.LNX.4.33.0410061116160.15729-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akepner@sgi.com
In-Reply-To: <Pine.LNX.4.33.0410061116160.15729-100000@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 6 Oct 2004 11:24:19 -0700 (PDT)
<akepner@sgi.com> wrote:

> Currently, returning 0 from "dev->poll()" indicates that the 
> PIO write which enables interrupts has been flushed to the NIC 
> (or at least that's my understanding.) The change below allows 
> "dev->poll()" to return with that PIO write pending, but not 
> necessarily flushed. This allows a potentially expensive PIO 
> flush to be avoided. I've found that this can significantly 
> reduce CPU utilization and improve throughput. 

Of course, this is a known area for exploration to some of
us already.

There is a similar place for this kind of toying around in
tg3_interrupt()'s disabling of the chips IRQs.  e1000 optimizes
things in this area, last time I checked.

You have to be really careful when doing things like this.
I think your dev->poll() case would work.  In theory the
write can be posted for a long time but I doubt that matters
in practice.

I intend to play around in this area of the tg3 driver some time
soon.
