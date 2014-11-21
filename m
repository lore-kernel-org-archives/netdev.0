From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxlan: move listen socket creation from workqueue to
 vxlan_open
Date: Fri, 21 Nov 2014 17:11:31 -0500 (EST)
Message-ID: <20141121.171131.1339829257521697510.davem@davemloft.net>
References: <a66c29751c354fe08acd459479f2eacf66e9b284.1416486751.git.mleitner@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	pshelar@nicira.com
To: mleitner@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39684 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097AbaKUWP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 17:15:28 -0500
In-Reply-To: <a66c29751c354fe08acd459479f2eacf66e9b284.1416486751.git.mleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Date: Thu, 20 Nov 2014 10:33:32 -0200

> But this doesn't apply to vxlan_open() scenario. We can unlock/lock
> in there safely and, with that, we can return a better error value
> to the user if that's the case.

This is not safe.

Now nothing prevents another parallel open of this vxlan device to
occur while you dropped the RTNL semaphore.
