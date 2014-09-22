From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: mld: answer mldv2 queries with mldv1
 reports in mldv1 fallback
Date: Mon, 22 Sep 2014 16:23:55 -0400 (EDT)
Message-ID: <20140922.162355.1814856663172821128.davem@davemloft.net>
References: <1411214635-14136-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53628 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754643AbaIVUX6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 16:23:58 -0400
In-Reply-To: <1411214635-14136-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Sat, 20 Sep 2014 14:03:55 +0200

> RFC2710 (MLDv1), section 3.7. says:
 ,,,
> RFC3810 (MLDv2), section 8.2.1. states for *listeners* regarding
> presence of MLDv1 routers:
 ...
> While section 8.3.1. specifies *router* behaviour regarding presence
> of MLDv1 routers:
 ...
> That means that we should not get queries from different versions of
> MLD. When there's a MLDv1 router present, MLDv2 enforces truncation
> and MRC == MRD (both fields are overlapping within the 24 octet range).
> 
> Section 8.3.2. specifies behaviour in the presence of MLDv1 multicast
> address *listeners*:
 ...
> That means, what can happen is the following scenario, that hosts can
> act in MLDv1 compatibility mode when they previously have received an
> MLDv1 query (or, simply operate in MLDv1 mode-only); and at the same
> time, an MLDv2 router could start up and transmits MLDv2 startup query
> messages while being unaware of the current operational mode.
> 
> Given RFC2710, section 3.7 we would need to answer to that with an MLDv1
> listener report, so that the router according to RFC3810, section 8.3.2.
> would receive that and internally switch to MLDv1 compatibility as well.
> 
> Right now, I believe since the initial implementation of MLDv2, Linux
> hosts would just silently drop such MLDv2 queries instead of replying
> with an MLDv1 listener report, which would prevent a MLDv2 router going
> into fallback mode (until it receives other MLDv1 queries).
> 
> Since the mapping of MRC to MRD in exactly such cases can make use of
> the exponential algorithm from 5.1.3, we cannot [strictly speaking] be
> aware in MLDv1 of the encoding in MRC, it seems also not mentioned by
> the RFC. Since encodings are the same up to 32767, assume in such a
> situation this value as a hard upper limit we would clamp. We have asked
> one of the RFC authors on that regard, and he mentioned that there seem
> not to be any implementations that make use of that exponential algorithm
> on startup messages. In any case, this patch fixes this MLD
> interoperability issue.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  [ Sending to net-next as it's nothing critical and nobody was screaming
>    out loud for so many years, so it can linger a bit in net-next first. ]

Applied, thanks Daniel.
