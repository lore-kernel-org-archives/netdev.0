From: David Gibson <hermes@gibson.dropbear.id.au>
Subject: Re: [PATCH] Fix readw/writew warnings in drivers/net/wireless/hermes.h
Date: Mon, 11 Oct 2004 22:31:37 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041011123137.GB28100@zax>
References: <Pine.LNX.4.61.0410110702590.7899@linaeum.absolutedigital.net> <416A7484.1030703@portrix.net> <1a50bd3704101105046e66538c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Dittmer <j.dittmer@portrix.net>, Cal Peake <cp@absolutedigital.net>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        NetDev Mailing List <netdev@oss.sgi.com>, proski@gnu.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Ricky lloyd <ricky.lloyd@gmail.com>
Content-Disposition: inline
In-Reply-To: <1a50bd3704101105046e66538c@mail.gmail.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Oct 11, 2004 at 05:34:20PM +0530, Ricky lloyd wrote:
> > Isn't the correct fix to declare iobase as (void __iomem *) ?
> > 
> 
> Earlier today i had posted a patch which mainly fixes this same
> problem with lotsa scsi
> drivers and tulip drivers. I wondered the same "shouldnt all the addrs
> be declared as
> void __iomem* ??". 

The trouble with that is that for some versions of the orinoco card,
the iobase refers to a legacy ISA IO address, not a memory-mapped IO
address (that's the inw()/outw() path in the macro).  That needs an
integer, rather than a pointer.

It's not clear to me which way around the cast is less ugly.

-- 
David Gibson			| For every complex problem there is a
david AT gibson.dropbear.id.au	| solution which is simple, neat and
				| wrong.
http://www.ozlabs.org/people/dgibson
