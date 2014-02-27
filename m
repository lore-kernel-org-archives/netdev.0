From: Aaron Brown <aaron.f.brown@intel.com>
Subject: Re: [PATCH net-next] ixgbevf: fix skb->pkt_type checks
Date: Thu, 27 Feb 2014 14:58:46 -0800
Message-ID: <1393541926.1931.4.camel@localhost>
References: <1393454640-19651-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	alexander.h.duyck@intel.com, jesse.brandeburg@intel.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:47155 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751150AbaB0W6s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 17:58:48 -0500
In-Reply-To: <1393454640-19651-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-02-26 at 14:44 -0800, Florian Fainelli wrote:
> skb->pkt_type is not a bitmask, but contains only value at a time from
> the range defined in include/uapi/linux/if_packet.h.
> 
> Checking it like if it was a bitmask of values would also cause
> PACKET_OTHERHOST, PACKET_LOOPBACK and PACKET_FASTROUTE to be matched by this
> check since their lower 2 bits are also set, although that does not fix a real
> bug due to how the checks are used, it is still potentially confusing.
> 
> This bogus check was introduced in commit 815cccbf ("ixgbe: add setlink,
> getlink support to ixgbe and ixgbevf").
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)

Thanks Florian, I have added this to our internal queue.
