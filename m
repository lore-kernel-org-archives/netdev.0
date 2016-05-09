From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: conntrack: remove uninitialized shadow
 variable
Date: Mon, 9 May 2016 22:01:17 +0200
Message-ID: <20160509200117.GA6957@salvia>
References: <1462823254-3137116-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Sasha Levin <sasha.levin@oracle.com>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54457 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751705AbcEIUBb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 16:01:31 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 92D63EAA6E
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 22:01:29 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 834DA134714
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 22:01:29 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 5044FFAB45
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 22:01:27 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <1462823254-3137116-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 09, 2016 at 09:47:23PM +0200, Arnd Bergmann wrote:
> A recent commit introduced an unconditional use of an uninitialized
> variable, as reported in this gcc warning:
> 
> net/netfilter/nf_conntrack_core.c: In function '__nf_conntrack_confirm':
> net/netfilter/nf_conntrack_core.c:632:33: error: 'ctinfo' may be used uninitialized in this function [-Werror=maybe-uninitialized]
>    bytes = atomic64_read(&counter[CTINFO2DIR(ctinfo)].bytes);
>                                  ^
> net/netfilter/nf_conntrack_core.c:628:26: note: 'ctinfo' was declared here
>    enum ip_conntrack_info ctinfo;
> 
> The problem is that a local variable shadows the function parameter.
> This removes the local variable, which looks like what Pablo originally
> intended.

Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>

Sorry for this, I wonder why gcc didn't catch up this here.

@David, you can integrate this into your net-next tree.

Thanks for fixing up this Arnd.
