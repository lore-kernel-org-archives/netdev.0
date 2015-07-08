From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rtnetlink: verify IFLA_VF_INFO attributes before
 passing them to driver
Date: Wed, 08 Jul 2015 16:02:37 -0700 (PDT)
Message-ID: <20150708.160237.452927104948461108.davem@davemloft.net>
References: <9b88c7217fcbf771efc162d51e3d6d1957707aa7.1436220184.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chrisw@sous-sol.org,
	sucheta.chakraborty@qlogic.com, gregory.v.rose@intel.com,
	jeffrey.t.kirsher@intel.com, ronye@mellanox.com,
	vladz@cloudius-systems.com, nicolas.dichtel@6wind.com,
	tgraf@suug.ch, jgunthorpe@obsidianresearch.com
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38190 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014AbbGHXCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 19:02:39 -0400
In-Reply-To: <9b88c7217fcbf771efc162d51e3d6d1957707aa7.1436220184.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Tue,  7 Jul 2015 00:07:52 +0200

> Jason Gunthorpe reported that since commit c02db8c6290b ("rtnetlink: make
> SR-IOV VF interface symmetric"), we don't verify IFLA_VF_INFO attributes
> anymore with respect to their policy, that is, ifla_vfinfo_policy[].
> 
> Before, they were part of ifla_policy[], but they have been nested since
> placed under IFLA_VFINFO_LIST, that contains the attribute IFLA_VF_INFO,
> which is another nested attribute for the actual VF attributes such as
> IFLA_VF_MAC, IFLA_VF_VLAN, etc.
> 
> Despite the policy being split out from ifla_policy[] in this commit,
> it's never applied anywhere. nla_for_each_nested() only does basic nla_ok()
> testing for struct nlattr, but it doesn't know about the data context and
> their requirements.
> 
> Fix, on top of Jason's initial work, does 1) parsing of the attributes
> with the right policy, and 2) using the resulting parsed attribute table
> from 1) instead of the nla_for_each_nested() loop (just like we used to
> do when still part of ifla_policy[]).
> 
> Reference: http://thread.gmane.org/gmane.linux.network/368913
> Fixes: c02db8c6290b ("rtnetlink: make SR-IOV VF interface symmetric")
> Reported-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
> Signed-off-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied and queued up for -stable, thanks.
