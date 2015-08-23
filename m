From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: FIB tracepoints
Date: Sun, 23 Aug 2015 15:40:35 -0700 (PDT)
Message-ID: <20150823.154035.2177267760911368368.davem@davemloft.net>
References: <1439912954-5830-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46933 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753143AbbHWWl0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 18:41:26 -0400
In-Reply-To: <1439912954-5830-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 18 Aug 2015 09:49:14 -0600

> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> I realize the sensitivity around adding tracepoints, but these have been
> invaluable developing the VRF device driver along with a return probe:
>   perf probe -a 'fib_table_lookup_ret=fib_table_lookup%return ret=%ax' 

If you want this to be considered seriously, you really have to capture
all of the parts of the flow key that can influence fib_table_lookup(),
not just src/dst/oif/iif.

Without the flags, for example, you can't even tell if it's a VRF
lookup our not.  And you'll need, at a minimum, the TOS and scope
as well.
