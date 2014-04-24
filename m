From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 3/5] net: filter: get rid of sock_fprog_kern
Date: Thu, 24 Apr 2014 16:02:37 -0400 (EDT)
Message-ID: <20140424.160237.1682834218902091375.davem@davemloft.net>
References: <1398321927-8845-1-git-send-email-dborkman@redhat.com>
	<1398321927-8845-4-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33913 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751177AbaDXUCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 16:02:39 -0400
In-Reply-To: <1398321927-8845-4-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu, 24 Apr 2014 08:45:25 +0200

> It is actually cleaner to just get rid of sock_fprog_kern structure.
> It's not really useful as we can just use sock_fprog structure as
> we do elsewhere in the kernel, this could throw some sparse false
> positives though, but getting rid of the structure duplication is
> probably the better way to go.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Acked-by: Alexei Starovoitov <ast@plumgrid.com>

But this is the whole point of sock_fprog_kern.

It's so that we can always have the correct type for the pointers, and
we can show cleanly (without lots of ugly casts) to sparse that whether
we expect a pointer to be a user or a kernel one.

I really don't like this change, sorry.
