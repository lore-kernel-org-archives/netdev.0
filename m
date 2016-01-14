From: Edward Cree <ecree@solarflare.com>
Subject: Re: [RFC PATCH 3/4] net: Store checksum result for offloaded GSO
 checksums
Date: Thu, 14 Jan 2016 12:02:33 +0000
Message-ID: <56978E59.4070406@solarflare.com>
References: <20160114045532.5119.56124.stgit@localhost.localdomain>
 <20160114051214.5119.63241.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Alexander Duyck <aduyck@mirantis.com>, <netdev@vger.kernel.org>,
	<tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:30511 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752841AbcANMCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2016 07:02:41 -0500
In-Reply-To: <20160114051214.5119.63241.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/01/16 05:12, Alexander Duyck wrote:
> In order to do that I replaced CHECKSUM_PARTIAL with
> CHECKSUM_UNNECESSARY in the case of us computing checksums for the outer
> header while skipping computing checksums for the inner headers.  We clean
> up the ip_summed flag and set it to either CHECKSUM_PARTIAL or
> CHECKSUM_NONE once we hand the packet off to the next lower level.
I feel like this should probably be mentioned in the comment at thetop of
 skbuff.h.  I think section E of that comment will need to be more or less
 completely re-written with this patch series.  In particular, if I'm
 understandingcorrectly, csum_start and csum_offset will point to the
 inner checksum (unless using RCO), same as they do without GSO.  And GSO
 will never offload multiple checksums (although TSO will still have to
 _edit_ multiple checksums).
Or better still, proper documentation of GSO and TSO would be nice :)
