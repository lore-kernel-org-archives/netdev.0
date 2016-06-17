From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sit: correct IP protocol used in ipip6_err
Date: Thu, 16 Jun 2016 17:11:17 -0700 (PDT)
Message-ID: <20160616.171117.1343979574932922705.davem@davemloft.net>
References: <1466064379-32355-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44457 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753996AbcFQALS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 20:11:18 -0400
In-Reply-To: <1466064379-32355-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Thu, 16 Jun 2016 17:06:19 +0900

> Since 32b8a8e59c9c ("sit: add IPv4 over IPv4 support")
> ipip6_err() may be called for packets whose IP protocol is
> IPPROTO_IPIP as well as those whose IP protocol is IPPROTO_IPV6.
> 
> In the case of IPPROTO_IPIP packets the correct protocol value is not
> passed to ipv4_update_pmtu() or ipv4_redirect().
> 
> This patch resolves this problem by using the IP protocol of the packet
> rather than a hard-coded value. This appears to be consistent
> with the usage of the protocol of a packet by icmp_socket_deliver()
> the caller of ipip6_err().
> 
> I was able to exercise the redirect case by using a setup where an ICMP
> redirect was received for the destination of the encapsulated packet.
> However, it appears that although incorrect the protocol field is not used
> in this case and thus no problem manifests.  On inspection it does not
> appear that a problem will manifest in the fragmentation needed/update pmtu
> case either.
> 
> In short I believe this is a cosmetic fix. None the less, the use of
> IPPROTO_IPV6 seems wrong and confusing.
> 
> Reviewed-by: Dinan Gunawardena <dinan.gunawardena@netronome.com>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

Applied to 'net' and queued up for -stable, thanks Simon.
