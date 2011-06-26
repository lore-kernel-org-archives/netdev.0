From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: SKB paged fragment lifecycle on receive
Date: Sun, 26 Jun 2011 13:25:44 +0300
Message-ID: <20110626102543.GA4961@redhat.com>
References: <1308930202.32717.144.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, xen-devel <xen-devel@lists.xensource.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Rusty Russell <rusty@rustcorp.com.au>, mashirle@us.ibm.com
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45073 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753127Ab1FZKZo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Jun 2011 06:25:44 -0400
Content-Disposition: inline
In-Reply-To: <1308930202.32717.144.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 24, 2011 at 04:43:22PM +0100, Ian Campbell wrote:
> In this mode guest data pages ("foreign pages") were mapped into the
> backend domain (using Xen grant-table functionality) and placed into the
> skb's paged frag list (skb_shinfo(skb)->frags, I hope I am using the
> right term). Once the page is finished with netback unmaps it in order
> to return it to the guest (we really want to avoid returning such pages
> to the general allocation pool!).

Are the pages writeable by the source guest while netback processes
them?  If yes, firewalling becomes unreliable as the packet can be
modified after it's checked, right?
Also, for guest to guest communication, do you wait for
the destination to stop looking at the packet in order
to return it to the source? If yes, can source guest
networking be disrupted by a slow destination?


> Jeremy Fitzhardinge and I subsequently
> looked at the possibility of a no-clone skb flag (i.e. always forcing a
> copy instead of a clone)

I think this is the approach that the patchset
'macvtap/vhost TX zero-copy support' takes.

> but IIRC honouring it universally turned into a
> very twisty maze with a number of nasty corner cases etc.

Any examples? Are they covered by the patchset above?

> FWIW I proposed a session on the subject for LPC this year.
We also plan to discuss this on kvm forum 2011
(colocated with linuxcon 2011).
http://www.linux-kvm.org/page/KVM_Forum_2011

-- 
MST
