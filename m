From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix flow labels when the traffic class is non-0
Date: Tue, 31 Jan 2017 13:17:47 -0500 (EST)
Message-ID: <20170131.131747.527470210930915539.davem@davemloft.net>
References: <20170130220942.19105-1-dmichail@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, netdev@vger.kernel.org, edumazet@google.com
To: dmichail@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40350 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751353AbdAaSRy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 13:17:54 -0500
In-Reply-To: <20170130220942.19105-1-dmichail@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dimitris Michailidis <dmichail@google.com>
Date: Mon, 30 Jan 2017 14:09:42 -0800

> ip6_make_flowlabel() determines the flow label for IPv6 packets. It's
> supposed to be passed a flow label, which it returns as is if non-0 and
> in some other cases, otherwise it calculates a new value.
> 
> The problem is callers often pass a flowi6.flowlabel, which may also
> contain traffic class bits. If the traffic class is non-0
> ip6_make_flowlabel() mistakes the non-0 it gets as a flow label and
> returns the whole thing. Thus it can return a 'flow label' longer than
> 20b and the low 20b of that is typically 0 resulting in packets with 0
> label. Moreover, different packets of a flow may be labeled differently.
> For a TCP flow with ECN non-payload and payload packets get different
> labels as exemplified by this pair of consecutive packets:
 ...
> Signed-off-by: Dimitris Michailidis <dmichail@google.com>

Applied, thanks Dimitris.
