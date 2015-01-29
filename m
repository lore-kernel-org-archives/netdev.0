From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2 net] sunvnet: set queue mapping when doing packet
 copies
Date: Thu, 29 Jan 2015 14:30:22 -0800
Message-ID: <1422570622.21689.41.camel@edumazet-glaptop2.roam.corp.google.com>
References: <54CA8D33.6020006@oracle.com>
	 <1422563996.21689.26.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150129.141558.2191091565448535105.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: david.stevens@oracle.com, netdev@vger.kernel.org,
	sowmini.varadhan@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:57251 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752179AbbA2Wa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 17:30:29 -0500
Received: by mail-ie0-f181.google.com with SMTP id rp18so257600iec.12
        for <netdev@vger.kernel.org>; Thu, 29 Jan 2015 14:30:28 -0800 (PST)
In-Reply-To: <20150129.141558.2191091565448535105.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-29 at 14:15 -0800, David Miller wrote:

> Then we need to fix skb_segment() too.

My concern was that skb_segment() could be used in rx paths, with quite
different destructor semantics.

While from ndo_start_xmit(), I believe sane destructors should not
depend on skb being invariant, sk 'refcount' must be using
skb->truesize.
