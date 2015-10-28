From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net 1/3] openvswitch: Fix double-free on ip_defrag()
 errors
Date: Tue, 27 Oct 2015 19:32:40 -0700 (PDT)
Message-ID: <20151027.193240.2120617002975981873.davem@davemloft.net>
References: <1445829710-11292-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, pablo@netfilter.org,
	azhou@nicira.com
To: joestringer@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44539 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754754AbbJ1CP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 22:15:59 -0400
In-Reply-To: <1445829710-11292-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joestringer@nicira.com>
Date: Sun, 25 Oct 2015 20:21:48 -0700

> If ip_defrag() returns an error other than -EINPROGRESS, then the skb is
> freed. When handle_fragments() passes this back up to
> do_execute_actions(), it will be freed again. Prevent this double free
> by never freeing the skb in do_execute_actions() for errors returned by
> ovs_ct_execute. Always free it in ovs_ct_execute() error paths instead.
> 
> Fixes: 7f8a436eaa2c ("openvswitch: Add conntrack action")
> Reported-by: Florian Westphal <fw@strlen.de>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Applied.
