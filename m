From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NET] ethtool: silence warning on bit loss
Date: Fri, 14 Oct 2016 16:06:25 -0400 (EDT)
Message-ID: <20161014.160625.256367812856122638.davem@davemloft.net>
References: <1476400435-18400-1-git-send-email-jesse.brandeburg@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52278 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756914AbcJNUMz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 16:12:55 -0400
In-Reply-To: <1476400435-18400-1-git-send-email-jesse.brandeburg@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Date: Thu, 13 Oct 2016 16:13:55 -0700

> Sparse was complaining when we went to prototype some code
> using ethtool_cmd_speed_set and SPEED_100000, which uses
> the upper 16 bits of __u32 speed for the first time.
> 
> CHECK
> ...
> .../uapi/linux/ethtool.h:123:28: warning:
>   cast truncates bits from constant value (186a0 becomes 86a0)
> 
> The warning is actually bogus, as no bits are really lost, but
> we can get rid of the sparse warning with this one small change.
> 
> Reported-by: Preethi Banala <preethi.banala@intel.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>

Ok, I'll apply this.

There were alternative suggestions but I like this patch
because it makes it explicit what is going on.

Just removing the u16 cast requires the reader to implicitly
understand and know the types in the structure.
