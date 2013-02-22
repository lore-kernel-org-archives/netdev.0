From: Sasha Levin <sasha.levin@oracle.com>
Subject: Re: batman-adv: gpf in batadv_slide_own_bcast_window
Date: Fri, 22 Feb 2013 13:37:06 -0500
Message-ID: <5127BAD2.1040007@oracle.com>
References: <5127A2AF.9030502@oracle.com> <20130222170621.GU3523@ritirata.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Marek Lindner <lindner_marek@yahoo.de>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	"David S. Miller" <davem@davemloft.net>,
	b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>
To: Antonio Quartulli <ordex@autistici.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:36334 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758226Ab3BVShn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 13:37:43 -0500
In-Reply-To: <20130222170621.GU3523@ritirata.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/22/2013 12:06 PM, Antonio Quartulli wrote:
> Hi Sasha and thank you very much for reporting this issue.
> 
> IIRC this is similar to a bug you already reported in the past.
> This bug should be the result of a race condition batman-adv has in the
> hard-interface handling code (this is why it has been triggered while removing
> eth0).
> 
> Now that the rtnl-deadlock has been solved I think we can try to further
> investigate on this bug and try to find a solution..though it will not be easy
> as it probably requires another lock to protect the hard-interface during this
> operations.
> 
> If you have any fix proposal feel free to contribute!

I'm confused about how batadv_orig_hash_del_if removes an interface from the
hashtable. I see the hashtable is using rcu to protect it, but when we
delete an entry we free it straight away by calling batadv_orig_node_del_if()
and not going through kfree_rcu().

Is there a reason behind doing that, or might it be the cause of the problem
we're seeing here?


Thanks,
Sasha
