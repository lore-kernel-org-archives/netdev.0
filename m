From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2 0/5] GRO Fixed IPv4 ID support and GSO
 partial support
Date: Thu, 14 Apr 2016 16:24:00 -0400 (EDT)
Message-ID: <20160414.162400.576736312272421011.davem@davemloft.net>
References: <20160411013855.11189.56567.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, tom@herbertland.com, jesse@kernel.org,
	alexander.duyck@gmail.com, edumazet@google.com,
	netdev@vger.kernel.org
To: aduyck@mirantis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40789 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239AbcDNUYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 16:24:05 -0400
In-Reply-To: <20160411013855.11189.56567.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>
Date: Sun, 10 Apr 2016 21:44:38 -0400

> This patch series sets up a few different things.
> 
> First it adds support for GRO of frames with a fixed IP ID value.  This
> will allow us to perform GRO for frames that go through things like an IPv6
> to IPv4 header translation.
> 
> The second item we add is support for segmenting frames that are generated
> this way.  Most devices only support an incrementing IP ID value, and in
> the case of TCP the IP ID can be ignored in many cases since the DF bit
> should be set.  So we can technically segment these frames using existing
> TSO if we are willing to allow the IP ID to be mangled.  As such I have
> added a matching feature for the new form of GRO/GSO called TCP IPv4 ID
> mangling.  With this enabled we can assemble and disassemble a frame with
> the sequence number fixed and the only ill effect will be that the IPv4 ID
> will be altered which may or may not have any noticeable effect.  As such I
> have defaulted the feature to disabled.
> 
> The third item this patch series adds is support for partial GSO
> segmentation.  Partial GSO segmentation allows us to split a large frame
> into two pieces.  The first piece will have an even multiple of MSS worth
> of data and the headers before the one pointed to by csum_start will have
> been updated so that they are correct for if the data payload had already
> been segmented.  By doing this we can do things such as precompute the
> outer header checksums for a frame to be segmented allowing us to perform
> TSO on devices that don't support tunneling, or tunneling with outer header
> checksums.
> 
> This patch set is based on the net-next tree, but I included "net: remove
> netdevice gso_min_segs" in my tree as I assume it is likely to be applied
> before this patch set will and I wanted to avoid a merge conflict.
> 
> v2: Fixed items reported by Jesse Gross
> 	fixed missing GSO flag in MPLS check
> 	adding DF check for MANGLEID
>     Moved extra GSO feature checks into gso_features_check
>     Rebased batches to account for "net: remove netdevice gso_min_segs"
> 
> Driver patches from the first patch set should still be compatible.  However
> I do have a few changes in them so I will submit a v2 of those to Jeff
> Kirsher once these patches are accepted into net-next.
> 
> Example driver patches for i40e, ixgbe, and igb:
> https://patchwork.ozlabs.org/patch/608221/
> https://patchwork.ozlabs.org/patch/608224/
> https://patchwork.ozlabs.org/patch/608225/

Series applied, thanks Alexander.
