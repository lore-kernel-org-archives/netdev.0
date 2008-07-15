From: David Miller <davem@davemloft.net>
Subject: netfilter merge conflict...
Date: Mon, 14 Jul 2008 20:31:07 -0700 (PDT)
Message-ID: <20080714.203107.107924149.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sfr@canb.auug.org.au
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49911
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753007AbYGODbG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 23:31:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Patrick, I had to resolve a conflict in nf_conntrack_proto_tcp.c when
I merged net-2.6 into net-next-2.6 in preparation for merging with
Linus.  This is the same one Stephen started hitting when building the
linux-next tree last week.

The problem is the looping fix.

What I did was first add a changeset that modifies __nf_ct_kill*() to
return a boolean that indicates if the del_timer() returned true.
This return value propagates through nf_ct_kill() as well.

Then I did the merge and resolved it by making the loop prevention code
look like:

			if (nf_ct_kill(ct))
				return -NF_REPEAT;
			return -NF_DROP;

Just FYI...  this is pushed out to net-next-2.6 if you want to have a
closer look.

Thanks.
