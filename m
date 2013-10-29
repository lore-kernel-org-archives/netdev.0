From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ipv4: fix DO and PROBE pmtu mode regarding
 local fragmentation with UFO/CORK
Date: Tue, 29 Oct 2013 00:16:35 -0400 (EDT)
Message-ID: <20131029.001635.269996972753973170.davem@davemloft.net>
References: <20131025194003.GG15744@order.stressinduktion.org>
	<20131027162911.GA4714@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40392 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751850Ab3J2EQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 00:16:36 -0400
In-Reply-To: <20131027162911.GA4714@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sun, 27 Oct 2013 17:29:11 +0100

> UFO as well as UDP_CORK do not respect IP_PMTUDISC_DO and
> IP_PMTUDISC_PROBE well enough.
> 
> UFO enabled packet delivery just appends all frags to the cork and hands
> it over to the network card. So we just deliver non-DF udp fragments
> (DF-flag may get overwritten by hardware or virtual UFO enabled
> interface).
> 
> UDP_CORK does enqueue the data until the cork is disengaged. At this
> point it sets the correct IP_DF and local_df flags and hands it over to
> ip_fragment which in this case will generate an icmp error which gets
> appended to the error socket queue. This is not reflected in the syscall
> error (of course, if UFO is enabled this also won't happen).
> 
> Improve this by checking the pmtudisc flags before appending data to the
> socket and if we still can fit all data in one packet when IP_PMTUDISC_DO
> or IP_PMTUDISC_PROBE is set, only then proceed.
> 
> We use (mtu-fragheaderlen) to check for the maximum length because we
> ensure not to generate a fragment and non-fragmented data does not need
> to have its length aligned on 64 bit boundaries. Also the passed in
> ip_options are already aligned correctly.
> 
> Maybe, we can relax some other checks around ip_fragment. This needs
> more research.
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
> v2:
>  Switch from maxfraglen to mtu for length check as outlined in the commit
>  message.

Looks good, applied.
