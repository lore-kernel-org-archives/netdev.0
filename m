From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_netlink: force credentials passing [CVE-2012-3520]
Date: Tue, 21 Aug 2012 14:53:38 -0700 (PDT)
Message-ID: <20120821.145338.589021419115918361.davem@davemloft.net>
References: <1345566077.5158.530.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pmatouse@redhat.com, fweimer@redhat.com,
	pablo@netfilter.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45263 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758482Ab2HUVxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 17:53:39 -0400
In-Reply-To: <1345566077.5158.530.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 21 Aug 2012 18:21:17 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Pablo Neira Ayuso discovered that avahi and 
> potentially NetworkManager accept spoofed Netlink messages because of a 
> kernel bug.  The kernel passes all-zero SCM_CREDENTIALS ancillary data 
> to the receiver if the sender did not provide such data, instead of not 
> including any such data at all or including the correct data from the 
> peer (as it is the case with AF_UNIX).
> 
> This bug was introduced in commit 16e572626961
> (af_unix: dont send SCM_CREDENTIALS by default)
> 
> This patch forces passing credentials for netlink, as
> before the regression.
> 
> Another fix would be to not add SCM_CREDENTIALS in
> netlink messages if not provided by the sender, but it
> might break some programs.
> 
> With help from Florian Weimer & Petr Matousek
> 
> This issue is designated as CVE-2012-3520
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.
