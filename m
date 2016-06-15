From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 01/15] net: Combine GENEVE and VXLAN port
 offload notifiers into single functions
Date: Wed, 15 Jun 2016 00:22:05 -0700 (PDT)
Message-ID: <20160615.002205.499467944175786.davem@davemloft.net>
References: <CAKgT0Uc8SZSsi9EULv0GVNO38OHhw__7_MDQ3PtDf-8y7+1Jgg@mail.gmail.com>
	<CALx6S359Q_qqj6Wc7K41hVfjzqHgLsHmH-91WTOS9tGw3=G5fA@mail.gmail.com>
	<CAKgT0Ue_-2KTMY6LsJjonTC7A16jB3hJZj+VU=4Fcp_9ZoNf+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, aduyck@mirantis.com, netdev@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, hannes@redhat.com,
	jesse@kernel.org, jbenc@redhat.com, saeedm@mellanox.com,
	ariel.elior@qlogic.com, Dept-GELinuxNICDev@qlogic.com,
	eugenia@mellanox.com, jesse.brandeburg@intel.com
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55163 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751493AbcFOHWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 03:22:07 -0400
In-Reply-To: <CAKgT0Ue_-2KTMY6LsJjonTC7A16jB3hJZj+VU=4Fcp_9ZoNf+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Mon, 13 Jun 2016 19:50:02 -0700

> I'm not going to speculate on what Dave's opinion on this is.  I'll
> wait to hear it from him.
> 
> My concern at this point is that we have several issues.  Specifically
> we have VXLAN-GPE trying to pass itself off as VXLAN when it clearly
> is not, and I know we are going to end up with somebody eventually
> trying to push this feature into the kernel.  I know for a fact there
> is hardware out there that already supports it.  I'm trying to get
> ahead of this and define what the interface is supposed to look like
> myself so that we don't end up with somebody unfamiliar with all this
> trying to push it.  This way we can avoid having some hardware vendor
> on a timeline trying to push it through quick as in the case of i40e,
> or somebody trying to get around it by just hard coding it into their
> driver like occurred with bnxt.
> 
> While I appreciate the opinion, outright refusing to enable the
> existing offloads is counterproductive.  There are customers out there
> that already have this hardware.  There are driver writers out there
> who are going to have to enable these features one way or another.  If
> we want to be obstructionists then I am sure they can just work around
> us and write up out-of-tree drivers and use something like module
> parameters to enable offloads on a specific port.  Most of these
> implementations only seem to support one port anyway.  I just thought
> it might be better to have this figured out in the kernel so that we
> didn't end up creating a bigger mess than needed with each vendor
> going off and doing their own out-of-tree implementation.

My plan is to try and properly balance the two side of this situation.

Realistically, and Alex is right on this, we shoot ourselves in the
foot by not supporting offloads that exist in hardware now even if
they are not generic.

So I would encourage Alex to keep working on his patch set and to
keep working on the feedback he is given.

Thanks.
