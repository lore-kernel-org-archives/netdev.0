From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: sctp: fix permissions for rto_alpha and
 rto_beta knobs
Date: Sun, 15 Jun 2014 01:18:30 -0700 (PDT)
Message-ID: <20140615.011830.1834645975843111936.davem@davemloft.net>
References: <1402786754-16807-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	vyasevich@gmail.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39131 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbaFOISc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2014 04:18:32 -0400
In-Reply-To: <1402786754-16807-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Sun, 15 Jun 2014 00:59:14 +0200

> Commit 3fd091e73b81 ("[SCTP]: Remove multiple levels of msecs
> to jiffies conversions.") has silently changed permissions for
> rto_alpha and rto_beta knobs from 0644 to 0444. The purpose of
> this was to discourage users from tweaking rto_alpha and
> rto_beta knobs in production environments since they are key
> to correctly compute rtt/srtt.
> 
> RFC4960 under section 6.3.1. RTO Calculation says regarding
> rto_alpha and rto_beta under rule C3 and C4:
 ...
> While it is discouraged to adjust rto_alpha and rto_beta
> and not further specified how to adjust them, the RFC also
> doesn't explicitly forbid it, but rather gives a RECOMMENDED
> default value (rto_alpha=3, rto_beta=2). We have a couple
> of users relying on the old permissions before they got
> changed. That said, if someone really has the urge to adjust
> them, we could allow it with a warning in the log.
> 
> Fixes: 3fd091e73b81 ("[SCTP]: Remove multiple levels of msecs to jiffies conversions.")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

This permission change seemed unintentional, and doesn't make
much sense anyways to me.

So I'm applying this, thanks Daniel.
