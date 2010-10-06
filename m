From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 PATCH] net: netif_set_real_num_rx_queues may cap
 num_rx_queues at init time
Date: Wed, 06 Oct 2010 16:07:13 +0100
Message-ID: <1286377633.2371.11.camel@achroite.uk.solarflarecom.com>
References: <20101004220042.3471.92774.stgit@jf-dev1-dcblab>
	 <1286256926.2457.2.camel@edumazet-laptop>  <4CAB4D8F.8080108@intel.com>
	 <1286296476.2307.5.camel@achroite.uk.solarflarecom.com>
	 <4CAB6447.6040407@intel.com>  <4CAC8D11.2060604@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"therbert@google.com" <therbert@google.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:34533 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932440Ab0JFPHR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 11:07:17 -0400
In-Reply-To: <4CAC8D11.2060604@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-10-06 at 07:52 -0700, John Fastabend wrote:
> On 10/5/2010 10:45 AM, John Fastabend wrote:
> > On 10/5/2010 9:34 AM, Ben Hutchings wrote:
> >> On Tue, 2010-10-05 at 09:08 -0700, John Fastabend wrote:
> >>> On 10/4/2010 10:35 PM, Eric Dumazet wrote:
[...]
> >>>> Why should we keep num_rx_queues > real_num_rx_queues ?
> >>>>
> >>>
> >>> If we do not ever need them then we should not keep them I agree.
> >>> But having netif_set_real_num_rx_queues set something other then
> >>> 'real_num_rx_queues' does not seem right to me at least. Also
> >>> netif_set_real_num_tx_queues and netif_set_real_num_rx_queues have
> >>> different behavior. It would be nice if this weren't the case but
> >>> they allocate queues in two places.
> >> [...]
> >>
> >> I only did this to satisfy Eric's desire to reduce memory usage.
> >> However, I believe that there are currently no drivers that dynamically
> >> increase numbers of RX or TX queues.  Until there are, there is not much
> >> point in removing this assignment to num_rx_queues.
> >>
> >> Ben.
> >>
> > 
> > ixgbe increases the real_num_[rx|tx]_queues when FCoE or DCB is enabled.
> > Also many of the drivers could increase the number of queues if they were
> > given more interrupt vectors at some point.
> 
> 
> If I update the handful drivers that use netif_set_real_num_rx_queues()
> before the netdevice is registered to explicitly set num_rx_queues this
> would address Eric's concerns and fix drivers that really only want to set
> real_num_rx_queue.
> 
> Any thoughts?

Don't add assignments to num_rx_queues.  If it's useful to increase the
number of RX queues later then just remove the assignment to
num_rx_queues from netif_set_real_num_rx_queues() and be done with it.
The waste of memory is minimal now that we only allocate kobjects for
real_num_rx_queues.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

