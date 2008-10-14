From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [PATCH] 2.6.27-rc9 QGLE make unsupported page size explicit compile failure
Date: Mon, 13 Oct 2008 19:53:29 -0700
Message-ID: <20081014025329.GA25397@susedev.qlogic.org>
References: <20081014015455.GA25385@susedev.qlogic.org> <20081013.190345.20202604.davem@davemloft.net> <20081014021902.GY25780@parisc-linux.org> <20081013.193153.203217396.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: matthew@wil.cx, grundler@parisc-linux.org, linux-driver@qlogic.com,
	netdev@vger.kernel.org, linux-ia64@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:30891 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753974AbYJNCxg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 22:53:36 -0400
Content-Disposition: inline
In-Reply-To: <20081013.193153.203217396.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 13, 2008 at 07:31:53PM -0700, David Miller wrote:
> From: Matthew Wilcox <matthew@wil.cx>
> Date: Mon, 13 Oct 2008 20:19:02 -0600
> 
> > On Mon, Oct 13, 2008 at 07:03:45PM -0700, David Miller wrote:
> > > From: Ron Mercer <ron.mercer@qlogic.com>
> > > Date: Mon, 13 Oct 2008 18:54:55 -0700
> > > 
> > > > This ASIC does support all page sizes. For 4k and 8k page size the TX control block needs an external scatter gather list.  For page sizes larger than 8k the max frags is satisfied by the original TX control block.
> > > 
> > > I'm not applying this.  I _explicitly_ said I would not apply a
> > > solution like this.
> > > 
> > > I waited for you guys all day for this?!?!
> > > 
> > > We need to find a way to make this a Kconfig dependency.
> > > 
> > > Build failures are absolutely unacceptable.
> > 
> > Um, Dave, I think you misread his patch.
> > 
> > All it does it make the '64k case' the 'every other size case'.  There's
> > no build failure with Ron's patch.
> 
> Thanks for the correction, I'll look at this again :)

My explanation might not have been very good.  What I was trying to say
is that the macro in question determines the size of a scatter/gathter
list that is external to the TX descriptor.  The size is based on
MAX_SKB_FRAGS and PAGE_SIZE.  When PAGE_SIZE is larger than 8k I don't
need the external scatter/gather list because all frags will fit in the
native TX descriptor.

