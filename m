From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net] macvlan: Disable LRO on lowerdev; warn if it's
 turned back on
Date: Tue, 21 Feb 2012 20:28:56 +0000
Message-ID: <1329856136.2689.46.camel@bwh-desktop>
References: <1329851622.2689.6.camel@bwh-desktop>
	 <4F43F816.6070908@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Shradha Shah <sshah@solarflare.com>,
	Patrick McHardy <kaber@trash.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:24733 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754933Ab2BUU3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 15:29:00 -0500
In-Reply-To: <4F43F816.6070908@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-02-21 at 12:01 -0800, John Fastabend wrote:
> On 2/21/2012 11:13 AM, Ben Hutchings wrote:
> > Large Receive Offload (LRO) is only appropriate for packets that are
> > destined for the host, and should be disabled if received packets may
> > be forwarded.
> > 
> > Further, macvtap_skb_to_vnet_hdr() will BUG() on a packet received
> > with LRO (but not GRO).
> > 
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> > ---
> > I'm not really familiar with macvlan so I'm not certain that this should
> > be applied to all modes.
> > 
> > Ben.
> > 
> >  drivers/net/macvlan.c |    7 +++++++
> >  1 files changed, 7 insertions(+), 0 deletions(-)
> > 
> 
> But this patch assumes the macvlan is forwarding traffic to a guest
> via macvtap. Which is an assumption that may not be true.
> 
> It seems more appropriate for the macvtap driver to do these checks
> after all its the driver that may BUG() with LRO.

That's what I thought at first, but then I looked through what macvlan
was doing and it certainly appears to re-transmit skbs in all modes.
That's not valid when gso_size != 0 and gso_type == 0.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
