From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH v3] GRE: Disable segmentation offloads w/ CSUM and
 we are encapsulated via FOU
Date: Thu, 07 Apr 2016 16:57:11 -0400 (EDT)
Message-ID: <20160407.165711.46922408670633362.davem@davemloft.net>
References: <20160405161249.3861.1683.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse@kernel.org, netdev@vger.kernel.org,
	alexander.duyck@gmail.com, tom@herbertland.com
To: aduyck@mirantis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55691 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754124AbcDGU5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 16:57:14 -0400
In-Reply-To: <20160405161249.3861.1683.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>
Date: Tue, 05 Apr 2016 09:13:39 -0700

> This patch fixes an issue I found in which we were dropping frames if we
> had enabled checksums on GRE headers that were encapsulated by either FOU
> or GUE.  Without this patch I was barely able to get 1 Gb/s of throughput.
> With this patch applied I am now at least getting around 6 Gb/s.
> 
> The issue is due to the fact that with FOU or GUE applied we do not provide
> a transport offset pointing to the GRE header, nor do we offload it in
> software as the GRE header is completely skipped by GSO and treated like a
> VXLAN or GENEVE type header.  As such we need to prevent the stack from
> generating it and also prevent GRE from generating it via any interface we
> create.
> 
> Fixes: c3483384ee511 ("gro: Allow tunnel stacking in the case of FOU/GUE")
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
> ---
> 
> v3: Basically the same patch as v1 and v2, but I am cutting it loose from
>     the IPv4 ID patch as that one will likely need to be resolved in
>     net-next.

Applied, thanks Alexander.
