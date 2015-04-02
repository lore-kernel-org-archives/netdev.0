From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH nf-next 02/14] net: untangle ip_fragment and bridge
 netfilter
Date: Wed, 01 Apr 2015 23:09:21 -0400 (EDT)
Message-ID: <20150401.230921.232085782289557923.davem@davemloft.net>
References: <1427920600-20366-1-git-send-email-fw@strlen.de>
	<1427920600-20366-3-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34690 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752091AbbDBDJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 23:09:23 -0400
In-Reply-To: <1427920600-20366-3-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed,  1 Apr 2015 22:36:28 +0200

> Add mtu arguments to ip_fragment and remove the bridge netfilter mtu
> helper.

I told you I disagree with this approach.  Anything that adds
an 'mtu' argument to ip_fragment() I am not even going to look
at seriously, there must be device context when you call that
function.

Furthermore, and even more importantly, right now what bridge
netfilter does with fragmentation is _terminally_ broken.  It
absolutely does not guarantee to preserve the geometry of the incoming
fragment stream.

This is why you must use something like GRO/GSO, which is built
to positively and provably preserve the geometry of SKBs as they
are packed and unpacked.
