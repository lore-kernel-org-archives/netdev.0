From: Cal Peake <cp@absolutedigital.net>
Subject: Re: [PATCH] Fix readw/writew warnings in drivers/net/wireless/hermes.h
Date: Mon, 11 Oct 2004 08:23:35 -0400 (EDT)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.61.0410110819370.8480@linaeum.absolutedigital.net>
References: <Pine.LNX.4.61.0410110702590.7899@linaeum.absolutedigital.net>
 <416A7484.1030703@portrix.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev Mailing List <netdev@oss.sgi.com>, proski@gnu.org,
	hermes@gibson.dropbear.id.au
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S268861AbUJKMXn@vger.kernel.org>
To: Jan Dittmer <j.dittmer@portrix.net>
In-Reply-To: <416A7484.1030703@portrix.net>
List-Id: netdev.vger.kernel.org

On Mon, 11 Oct 2004, Jan Dittmer wrote:

> Cal Peake wrote:
> 
> >  	inw((hw)->iobase + ( (off) << (hw)->reg_spacing )) : \
> > -	readw((hw)->iobase + ( (off) << (hw)->reg_spacing )))
> > +	readw((void __iomem *)(hw)->iobase + ( (off) << (hw)->reg_spacing )))
> >  #define hermes_write_reg(hw, off, val) do { \
> 
> Isn't the correct fix to declare iobase as (void __iomem *) ?

iobase is an unsigned long, declaring it as a void pointer is prolly not 
what we want to do here. The typecast seems proper. A lot of other drivers 
do this as well thus it must be proper ;-)

-- Cal
