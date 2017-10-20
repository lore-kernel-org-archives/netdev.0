From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH 0/5] sockmap fixes for net
Date: Fri, 20 Oct 2017 13:01:46 +0100 (WEST)
Message-ID: <20171020.130146.78146147934317055.davem@davemloft.net>
References: <150833522977.3588.14633565129152334098.stgit@john-XPS-13-9360>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        borkmann@iogearbox.net
To: john.r.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37112 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753114AbdJTMBu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 08:01:50 -0400
In-Reply-To: <150833522977.3588.14633565129152334098.stgit@john-XPS-13-9360>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@gmail.com>
Date: Wed, 18 Oct 2017 07:09:48 -0700

> The following implements a set of fixes for sockmap and changes the
> API slightly in a few places to reduce preempt_disable/enable scope.
> We do this here in net because it requires an API change and this
> avoids getting stuck with legacy API going forward.
> 
> The short description:
> 
> Access to skb mark is removed, it is problematic when we add
> features in the future because mark is a union and used by the
> TCP/socket code internally. We don't want to expose this to the
> BPF programs or let programs change the values.
> 
> The other change is caching metadata in the skb itself between
> when the BPF program returns a redirect code and the core code
> implements the redirect. This avoids having per cpu metadata.
> 
> Finally, tighten restriction on using sockmap to CAP_NET_ADMIN and
> only SOCK_STREAM sockets.

Series applied, thanks.
