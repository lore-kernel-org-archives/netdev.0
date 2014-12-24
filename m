From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: Generalize ndo_gso_check to ndo_features_check
Date: Tue, 23 Dec 2014 23:52:38 -0500 (EST)
Message-ID: <20141223.235238.1958837159787674842.davem@davemloft.net>
References: <1419264223-30004-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com,
	joestringer@nicira.com, edumazet@google.com
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36197 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104AbaLXEwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2014 23:52:42 -0500
In-Reply-To: <1419264223-30004-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Mon, 22 Dec 2014 08:03:43 -0800

> GSO isn't the only offload feature with restrictions that
> potentially can't be expressed with the current features mechanism.
> Checksum is another although it's a general issue that could in
> theory apply to anything. Even if it may be possible to
> implement these restrictions in other ways, it can result in
> duplicate code or inefficient per-packet behavior.
> 
> This generalizes ndo_gso_check so that drivers can remove any
> features that don't make sense for a given packet, similar to
> netif_skb_features(). It also converts existing driver
> restrictions to the new format, completing the work that was
> done to support tunnel protocols since the issues apply to
> checksums as well.
> 
> CC: Tom Herbert <therbert@google.com>
> CC: Joe Stringer <joestringer@nicira.com>
> CC: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Jesse Gross <jesse@nicira.com>
> Fixes: 04ffcb255f22 ("net: Add ndo_gso_check")

I don't think this fixes the case which was the main impetus for Eric
Dumazet's patch.

The r8152 USB networking driver supports TSO, but has a length
restriction, and we weren't software segmenting when netif_needs_gso()
returns true, exactly because we didn't clear TSO from the feature
flags.

We really need to sort this out.
