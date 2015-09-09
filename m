From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv1 net] xen-netback: require fewer guest Rx slots when
 not using GSO
Date: Wed, 09 Sep 2015 12:34:59 -0700 (PDT)
Message-ID: <20150909.123459.1956039261743477106.davem@davemloft.net>
References: <1441718714-3256-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	ian.campbell@citrix.com, wei.liu2@citrix.com
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34322 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808AbbIITfA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 15:35:00 -0400
In-Reply-To: <1441718714-3256-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Tue, 8 Sep 2015 14:25:14 +0100

> Commit f48da8b14d04ca87ffcffe68829afd45f926ec6a (xen-netback: fix
> unlimited guest Rx internal queue and carrier flapping) introduced a
> regression.
> 
> The PV frontend in IPXE only places 4 requests on the guest Rx ring.
> Since netback required at least (MAX_SKB_FRAGS + 1) slots, IPXE could
> not receive any packets.
> 
> a) If GSO is not enabled on the VIF, fewer guest Rx slots are required
>    for the largest possible packet.  Calculate the required slots
>    based on the maximum GSO size or the MTU.
> 
>    This calculation of the number of required slots relies on
>    1650d5455bd2 (xen-netback: always fully coalesce guest Rx packets)
>    which present in 4.0-rc1 and later.
> 
> b) Reduce the Rx stall detection to checking for at least one
>    available Rx request.  This is fine since we're predominately
>    concerned with detecting interfaces which are down and thus have
>    zero available Rx requests.
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Applied, thanks David.
