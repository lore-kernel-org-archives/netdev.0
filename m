From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] vxlan: Set a large MTU on ovs-created vxlan
 devices
Date: Thu, 07 Jan 2016 16:47:46 -0500 (EST)
Message-ID: <20160107.164746.548558171283936394.davem@davemloft.net>
References: <1452087186-12926-1-git-send-email-david@weave.works>
	<20160106.155950.1007160228570301281.davem@davemloft.net>
	<8660z6qohn.fsf@weave.works>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: david@weave.works
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52745 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752552AbcAGVrs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 16:47:48 -0500
In-Reply-To: <8660z6qohn.fsf@weave.works>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Wragg <david@weave.works>
Date: Wed, 06 Jan 2016 23:25:56 +0000

> Considering non-openvswitch scenarios, when using vxlan netdevs
> directly, a vxlan netdev locked to an underlying device supporting jumbo
> frames can use a larger MTU.  It's only vxlan netdevs without an
> underlying device that have the limit of 1500 imposed.  But why
> shouldn't there be the same flexibility to select an MTU for best
> performance in both cases?  Aren't the fragmentation concerns the same?

When there is an underlying device, there are no fragmentation concerns
and PMTU will function properly because the MTU will be set accurately.

> True.  But in what sense is 1500 accurate?  Uses/users of the kernel
> openvswitch code have always had to get this right, making sure that
> the MTU set on a vxlan overlay network conforms to the underlying
> network paths involved.

"right" is a subjective thing.

Here, once again, the poorly thought out amount of flexibility
openvswitch provides is going to have a serious negative consequence
for our implementation.

I'm really tired of seeing this happen over and over again.
Openvswitch's growth and the expansion of it's feature set was
extremely poorly managed.
