From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: reasons for dev_alloc_skb +16?
Date: Wed, 9 Jul 2003 12:06:57 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030709160657.GD15293@gtf.org>
References: <20030709152553.GB15293@gtf.org> <20030709175355.422545b5.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <20030709175355.422545b5.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jul 09, 2003 at 05:53:55PM +0200, Andi Kleen wrote:
> On Wed, 9 Jul 2003 11:25:53 -0400
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
> > I knew this at one time, but have forgotten it :)
> > 
> > What is the reason for adding 16 to the dev_alloc_skb length?
> > (and skb_reserve of the same length)
> 
> For the skb_reserve alignment to align the IP header. 
> 
> But it's not clear it is still a good idea because it leads to cache line 
> misalignment of the beginning of the packet, forcing the card to do a
> costly Read-Modify-Write cycle.

Exactly.  Ben H is running into this, and pondering direct use of
alloc_skb for precisely this reason.

	Jeff
