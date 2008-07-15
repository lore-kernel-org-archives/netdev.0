From: Patrick McHardy <kaber@trash.net>
Subject: Re: netfilter merge conflict...
Date: Tue, 15 Jul 2008 05:53:29 +0200
Message-ID: <487C1F39.9020003@trash.net>
References: <20080714.203107.107924149.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sfr@canb.auug.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43400 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752189AbYGOD7J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 23:59:09 -0400
In-Reply-To: <20080714.203107.107924149.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> Patrick, I had to resolve a conflict in nf_conntrack_proto_tcp.c when
> I merged net-2.6 into net-next-2.6 in preparation for merging with
> Linus.  This is the same one Stephen started hitting when building the
> linux-next tree last week.
>
> The problem is the looping fix.
>
> What I did was first add a changeset that modifies __nf_ct_kill*() to
> return a boolean that indicates if the del_timer() returned true.
> This return value propagates through nf_ct_kill() as well.
>
> Then I did the merge and resolved it by making the loop prevention code
> look like:
>
> 			if (nf_ct_kill(ct))
> 				return -NF_REPEAT;
> 			return -NF_DROP;
>
> Just FYI...  this is pushed out to net-next-2.6 if you want to have a
> closer look.

The patch looks good, thanks for fixing this.
