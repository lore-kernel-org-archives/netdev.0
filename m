From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: openvswitch: Support masked set actions.
Date: Sat, 07 Feb 2015 22:40:30 -0800 (PST)
Message-ID: <20150207.224030.956562145941593900.davem@davemloft.net>
References: <1423172449-3654-1-git-send-email-jrajahalme@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: jrajahalme@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47147 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751634AbbBHGkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2015 01:40:31 -0500
In-Reply-To: <1423172449-3654-1-git-send-email-jrajahalme@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarno Rajahalme <jrajahalme@nicira.com>
Date: Thu,  5 Feb 2015 13:40:49 -0800

> OVS userspace already probes the openvswitch kernel module for
> OVS_ACTION_ATTR_SET_MASKED support.  This patch adds the kernel module
> implementation of masked set actions.
> 
> The existing set action sets many fields at once.  When only a subset
> of the IP header fields, for example, should be modified, all the IP
> fields need to be exact matched so that the other field values can be
> copied to the set action.  A masked set action allows modification of
> an arbitrary subset of the supported header bits without requiring the
> rest to be matched.
> 
> Masked set action is now supported for all writeable key types, except
> for the tunnel key.  The set tunnel action is an exception as any
> input tunnel info is cleared before action processing starts, so there
> is no tunnel info to mask.
> 
> The kernel module converts all (non-tunnel) set actions to masked set
> actions.  This makes action processing more uniform, and results in
> less branching and duplicating the action processing code.  When
> returning actions to userspace, the fully masked set actions are
> converted back to normal set actions.  We use a kernel internal action
> code to be able to tell the userspace provided and converted masked
> set actions apart.
> 
> Signed-off-by: Jarno Rajahalme <jrajahalme@nicira.com>
> ---
> v3: Clean up code and remove flow key transport port checks from
>     validate_set(), as suggested by Jesse Gross.

Applied, thanks.
