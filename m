From: David Gibson <hermes@gibson.dropbear.id.au>
Subject: Re: [PATCH] Fix readw/writew warnings in drivers/net/wireless/hermes.h
Date: Mon, 11 Oct 2004 22:32:17 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041011123217.GC28100@zax>
References: <Pine.LNX.4.61.0410110702590.7899@linaeum.absolutedigital.net> <416A7484.1030703@portrix.net> <Pine.LNX.4.61.0410110819370.8480@linaeum.absolutedigital.net> <416A7CB3.9000003@portrix.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cal Peake <cp@absolutedigital.net>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        NetDev Mailing List <netdev@oss.sgi.com>, proski@gnu.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jan Dittmer <j.dittmer@portrix.net>
Content-Disposition: inline
In-Reply-To: <416A7CB3.9000003@portrix.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Oct 11, 2004 at 02:29:39PM +0200, Jan Dittmer wrote:
> Cal Peake wrote:
> >On Mon, 11 Oct 2004, Jan Dittmer wrote:
> >
> >
> >>Cal Peake wrote:
> >>
> >>
> >>>	inw((hw)->iobase + ( (off) << (hw)->reg_spacing )) : \
> >>>-	readw((hw)->iobase + ( (off) << (hw)->reg_spacing )))
> >>>+	readw((void __iomem *)(hw)->iobase + ( (off) << (hw)->reg_spacing )))
> >>>#define hermes_write_reg(hw, off, val) do { \
> >>
> >>Isn't the correct fix to declare iobase as (void __iomem *) ?
> >
> >
> >iobase is an unsigned long, declaring it as a void pointer is prolly not 
> >what we want to do here. The typecast seems proper. A lot of other drivers 
> >do this as well thus it must be proper ;-)
> 
> Why is iobase a unsigned long in the first place? Isn't this broken for 
> 64bit archs?

Um, no.

-- 
David Gibson			| For every complex problem there is a
david AT gibson.dropbear.id.au	| solution which is simple, neat and
				| wrong.
http://www.ozlabs.org/people/dgibson
