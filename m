From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: Add fib rules at vrf device create
Date: Tue, 08 Dec 2015 21:44:11 -0500 (EST)
Message-ID: <20151208.214411.2137019448940208712.davem@davemloft.net>
References: <1449607685-8910-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48507 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751418AbbLICoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 21:44:13 -0500
In-Reply-To: <1449607685-8910-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue,  8 Dec 2015 12:48:05 -0800

> VRFs require ip rules for route lookups to work properly. Currently
> creating a VRF means instantiating a device and then adding the 4 ip
> and ip6 rules:
> 
>     ip link add vrf-${VRF} type vrf table ${TBID}
>     ip ru add oif vrf-${VRF} table ${TBID}
>     ip ru add iif vrf-${VRF} table ${TBID}
>     ip -6 ru add oif vrf-${VRF} table $TBID
>     ip -6 ru add iif vrf-${VRF} table $TBID
> 
> Since the table is required when the vrf device is created the rules can
> be inserted automatically lightening the overhead and improving the
> user experience (only the ip link add is needed).
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> v2
> - addressed comments from Nik

Unfortunately it's too late for this, you should have considered this
issue fully when VRF first went into an upstream release.

If I add your change, the user experience is _worse_.

Users on older kernels have to use the full sequence, then if they
upgrade their kernels to one with this patch then the 'ru add' et
al. commands will fail.
