From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH stable <= 3.18] net: add length argument to
 skb_copy_and_csum_datagram_iovec
Date: Thu, 29 Oct 2015 11:00:21 +0100
Message-ID: <20151029100021.GA17588@bistromath.redhat.com>
References: <c1b23313f94ba3fd9977c6fba61483edf6489b5f.1444910940.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: herbert@gondor.apana.org.au, stable@vger.kernel.org,
	hannes@stressinduktion.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57758 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750927AbbJ2KAY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2015 06:00:24 -0400
Content-Disposition: inline
In-Reply-To: <c1b23313f94ba3fd9977c6fba61483edf6489b5f.1444910940.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-10-15, 14:25:03 +0200, Sabrina Dubroca wrote:
> Without this length argument, we can read past the end of the iovec in
> memcpy_toiovec because we have no way of knowing the total length of the
> iovec's buffers.
> 
> This is needed for stable kernels where 89c22d8c3b27 ("net: Fix skb
> csum races when peeking") has been backported but that don't have the
> ioviter conversion, which is almost all the stable trees <= 3.18.
> 
> This also fixes a kernel crash for NFS servers when the client uses
>  -onfsvers=3,proto=udp to mount the export.
> 
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Fixes CVE-2015-8019.
http://www.openwall.com/lists/oss-security/2015/10/29/1

-- 
Sabrina
