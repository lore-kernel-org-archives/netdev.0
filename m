From: viro@parcelfarce.linux.theplanet.co.uk
Subject: Re: [PATCH] Fix readw/writew warnings in drivers/net/wireless/hermes.h
Date: Mon, 11 Oct 2004 14:16:03 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041011131603.GU23987@parcelfarce.linux.theplanet.co.uk>
References: <Pine.LNX.4.61.0410110702590.7899@linaeum.absolutedigital.net> <416A7484.1030703@portrix.net> <Pine.LNX.4.61.0410110819370.8480@linaeum.absolutedigital.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Dittmer <j.dittmer@portrix.net>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        NetDev Mailing List <netdev@oss.sgi.com>, proski@gnu.org,
        hermes@gibson.dropbear.id.au
Return-path: <netdev-bounce@oss.sgi.com>
To: Cal Peake <cp@absolutedigital.net>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0410110819370.8480@linaeum.absolutedigital.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Oct 11, 2004 at 08:23:35AM -0400, Cal Peake wrote:
> On Mon, 11 Oct 2004, Jan Dittmer wrote:
> 
> > Cal Peake wrote:
> > 
> > >  	inw((hw)->iobase + ( (off) << (hw)->reg_spacing )) : \
> > > -	readw((hw)->iobase + ( (off) << (hw)->reg_spacing )))
> > > +	readw((void __iomem *)(hw)->iobase + ( (off) << (hw)->reg_spacing )))
> > >  #define hermes_write_reg(hw, off, val) do { \
> > 
> > Isn't the correct fix to declare iobase as (void __iomem *) ?
> 
> iobase is an unsigned long, declaring it as a void pointer is prolly not 
> what we want to do here. The typecast seems proper. A lot of other drivers 
> do this as well thus it must be proper ;-)

Typecast is not a proper solution here.   Folks, there are cleanups underway
for all that mess, but it's not _that_ simple.

And adding casts to shut the warnings up is wrong in 99% of cases.
