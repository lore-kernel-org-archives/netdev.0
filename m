From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: [RFT][PATCH] cleanup net/atm/br2684.c
Date: Tue, 12 Aug 2003 18:09:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030813010917.GC36444@gaz.sfgoth.com>
References: <20030811114823.5b81474c.shemminger@osdl.org> <20030811215857.GA96728@gaz.sfgoth.com> <20030811153039.6df304fb.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chas williams <chas@cmf.nrl.navy.mil>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20030811153039.6df304fb.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> > Mmmm.. I see this snippet in your diff in multiplce places and it looks
> > wrong.  Where does the "brdev" structure get freed now?
> > 
> The brdev structure is contained inside the allocation of net_device,
> this is how all the ether and other devices do it.

OK, sorry... that should have been obvious.  The reason I was confused is
that almost always the net_dev is referenced as brdev->net_dev which makes
look like brdev merely has a reference to net_dev.  I think it would be
cleaner to change the code to pass around "net_dev" instead of "brdev"
references (and just get the brdev via net_dev->priv as needed) and just
get rid of the brdev->net_dev pointer entirely.

Are you interested in doing that?  Otherwise I could take a crack at it
when I get the chance (I've done some surgery on this file before)

-Mitch
