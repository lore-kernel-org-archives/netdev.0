From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net] macvlan: Disable LRO on lowerdev; warn if it's turned
 back on
Date: Tue, 21 Feb 2012 12:01:26 -0800
Message-ID: <4F43F816.6070908@intel.com>
References: <1329851622.2689.6.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Shradha Shah <sshah@solarflare.com>,
	Patrick McHardy <kaber@trash.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:23406 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756195Ab2BUUB1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Feb 2012 15:01:27 -0500
In-Reply-To: <1329851622.2689.6.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/21/2012 11:13 AM, Ben Hutchings wrote:
> Large Receive Offload (LRO) is only appropriate for packets that are
> destined for the host, and should be disabled if received packets may
> be forwarded.
> 
> Further, macvtap_skb_to_vnet_hdr() will BUG() on a packet received
> with LRO (but not GRO).
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> I'm not really familiar with macvlan so I'm not certain that this should
> be applied to all modes.
> 
> Ben.
> 
>  drivers/net/macvlan.c |    7 +++++++
>  1 files changed, 7 insertions(+), 0 deletions(-)
> 

But this patch assumes the macvlan is forwarding traffic to a guest
via macvtap. Which is an assumption that may not be true.

It seems more appropriate for the macvtap driver to do these checks
after all its the driver that may BUG() with LRO.

Thanks,
John
