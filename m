From: Paul Gortmaker <p_gortmaker@yahoo.com>
Subject: Re: [PATCH] switch sdla to initcalls
Date: Thu, 22 May 2003 00:59:08 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3ECC834B.E4045EB1@yahoo.com>
References: <20030521081938.GD22869@wotan.suse.de>
		<20030521102512.A30373@lst.de>
		<20030521082630.GF22869@wotan.suse.de>
		<20030521.013453.118618445.davem@redhat.com> <20030521123123.40924dce.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, hch@lst.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> 
> On Wed, 21 May 2003 01:34:53 -0700 (PDT)
> "David S. Miller" <davem@redhat.com> wrote:
> 
> > I have to admit that I must feign ignorance here.  And that someone
> > who really understands the EISA/ISA probe ordering requirements
> > should document them as best as possible in Space.c
> 
> I doubt anybody understands it. It is just lots of hard earned ad-hoc
> experience distilled in these files.

This used to be important many years ago when distribution kernels came 
with a bunch of compiled in ISA drivers.  I don't think it is anything
to get too worried about anymore.  Now a distribution is going to have
the ISA drivers as modules, and custom kernels with compiled in drivers
(probing via Space.c) are going to have a very limited set of drivers.

But regardless, the probe ordering was generally "newer before older", 
"more common before less common", and "invasive write before read type 
probes at the bottom".  This was just common-sense ordering, there
weren't that many cases where ordering was critical.  The only one that 
comes to mind now was smc-ultra.c vs wd.c (required "newer before older").
Things like ISA SCSI drivers probing into ne2000 cards was more of a
problem than net drivers screwing each other up back then.

> It's basically untestable/unknown because you'll likely have a hard time
> to find such a card anymore. And even if you had you would need the other
> ISA cards that could possible conflicts to test all combinations - impossible

Again, I wouldn't give too much weight to this issue -- it is safe to say
that all combinations of all cards at all I/O locations with all drivers
was never tested, and was never guaranteed to work either.  In fact if 
you look back, the "reserve=0xNNN" was introduced specifically to handle
corner cases where you had some other probe stomping on an ISA ethercard.
Now this is a totally unused and mostly forgot about boot prompt.

> task. For such unsolvable problems it is best to leave it untouched because it
> cannot be tested. Either that or remove the driver completely.

As an alternative to removal, you could always make the driver in
question as module only, and then the burden of probing order is on 
the installer or end user, as it is with all other modules currently.

Paul.

> 
> -Andi
