From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv1 net] xen-netback: support frontends without
 feature-rx-notify again
Date: Thu, 18 Dec 2014 12:50:09 -0500 (EST)
Message-ID: <20141218.125009.1837191564956948256.davem@davemloft.net>
References: <1418901186-14478-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	ian.campbell@citrix.com, wei.liu2@citrix.com
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47148 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009AbaLRRuL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2014 12:50:11 -0500
In-Reply-To: <1418901186-14478-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Thu, 18 Dec 2014 11:13:06 +0000

> Commit bc96f648df1bbc2729abbb84513cf4f64273a1f1 (xen-netback: make
> feature-rx-notify mandatory) incorrectly assumed that there were no
> frontends in use that did not support this feature.  But the frontend
> driver in MiniOS does not and since this is used by (qemu) stubdoms,
> these stopped working.
> 
> Netback sort of works as-is in this mode except:
> 
> - If there are no Rx requests and the internal Rx queue fills, only
>   the drain timeout will wake the thread.  The default drain timeout
>   of 10 s would give unacceptable pauses.
> 
> - If an Rx stall was detected and the internal Rx queue is drained,
>   then the Rx thread would never wake.
> 
> Handle these two cases (when feature-rx-notify is disabled) by:
> 
> - Reducing the drain timeout to 30 ms.
> 
> - Disabling Rx stall detection.
> 
> Reported-by: John <jw@nuclearfallout.net>
> Tested-by: John <jw@nuclearfallout.net>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Applied, and I assume that 3.18 -stable needs this as well?

Thanks.
