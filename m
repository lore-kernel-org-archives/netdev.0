From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: How do I track TG3 peculiarities?
Date: 12 Sep 2003 11:45:57 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m1r82llx2i.fsf@ebiederm.dsl.xmission.com>
References: <m31xuss0ht.fsf@maxwell.lnxi.com>
	<20030907220926.G18482@schatzie.adilger.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, "David S. Miller" <davem@redhat.com>,
   netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Andreas Dilger <adilger@clusterfs.com>
In-Reply-To: <20030907220926.G18482@schatzie.adilger.int>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andreas Dilger <adilger@clusterfs.com> writes:

> On Sep 07, 2003  16:21 -0600, Eric W. Biederman wrote:
> > Below is one good oops we have captured.  I would have to check but
> > I believe we have updated the tg3 driver in this instance to the
> > one that comes with 2.4.23-pre3.
> > 
> > The very puzzling part is that in the crashes I don't see the tg3
> > driver at all just the network stack.  All module addresses according
> > to /proc/ksyms started with at 0xf8, and the tg3 driver was built as
> > a module.
> > 
> > I have been having trouble understanding why skb_clone would be called
> > to transmit a packet.  Any ideas?
> 
> Do you have the stack overflow checking enabled?  
No. 
> That has been a source
> of problems for us.  It was especially difficult to reproduce, because it
> only happened during a double interrupt.


So a quick update on what I am seeing.

I have now tried with a myriad of driver and kernel versions watching very
carefully for a pattern.

What I have observed is memory corruption in what looks like it may
be a confined area of memory.  The ECC SDRAM is being closely
monitored and I am not getting as much as a correctable error much
less and uncorrectable error that would show up so memory is ruled
out.  When I am connected to a particular Extreme Networks gigabit
switch.  (The switch has some problems and it is hypothesized the
switch is injecting problematic packets into the network).

Bad packets should not be a problem but it looks like they are
triggering the problem whatever it is.

Eric
