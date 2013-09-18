From: David Miller <davem@davemloft.net>
Subject: Re: [CFT][PATCH] net: Delay default_device_exit_batch until no
 devices are unregistering
Date: Tue, 17 Sep 2013 20:15:15 -0400 (EDT)
Message-ID: <20130917.201515.1404443973169590392.davem@davemloft.net>
References: <87mwncaz04.fsf_-_@xmission.com>
	<20130917.192158.941189471705765317.davem@davemloft.net>
	<e652a11e-b23d-4a83-aaac-00c469a416f1@email.android.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fruggeri@aristanetworks.com, edumazet@google.com, jiri@resnulli.us,
	alexander.h.duyck@intel.com, amwang@redhat.com,
	netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44856 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752890Ab3IRAPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 20:15:17 -0400
In-Reply-To: <e652a11e-b23d-4a83-aaac-00c469a416f1@email.android.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Tue, 17 Sep 2013 16:41:37 -0700

> List/count I don't much care but currently we don't have a list of
> all of the devices that are unregistering.
> 
> The problem with this is that netdev_run_todo moves all of the
> devices to a local list, so they are only visible from a list_head
> on the stack.  Which makes sense as we run this all in the context
> of rtnl_unlock.

And when that local list is processed (the while loop completes and
has iterated over the entire list), either the global todo list is
empty, or it is not empty.

And the waked up code will check for this.

I really don't see what the problem is.
