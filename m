From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH 0/2] IPv4 FIB suffix length fixes
Date: Mon, 05 Dec 2016 13:16:19 -0500 (EST)
Message-ID: <20161205.131619.821937935676070514.davem@davemloft.net>
References: <20161201121605.15499.13176.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rshearma@brocade.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47306 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751530AbcLESQ1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 13:16:27 -0500
In-Reply-To: <20161201121605.15499.13176.stgit@ahduyck-blue-test.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Thu, 01 Dec 2016 07:27:47 -0500

> In reviewing the patch from Robert Shearman and looking over the code I
> realized there were a few different bugs we were still carrying in the IPv4
> FIB lookup code.
> 
> These two patches are based off of Robert's original patch, but take things
> one step further by splitting them up to address two additional issues I
> found.
> 
> So first have Robert's original patch which was addressing the fact that
> us calling update_suffix in resize is expensive when it is called per add.
> To address that I incorporated the core bit of the patch which was us
> dropping the update_suffix call from resize.
> 
> The first patch in the series does a rename and fix on the push_suffix and
> pull_suffix code.  Specifically we drop the need to pass a leaf and
> secondly we fix things so we pull the suffix as long as the value of the
> suffix in the node is dropping.
> 
> The second patch addresses the original issue reported as well as
> optimizing the code for the fact that update_suffix is only really meant to
> go through and clean things up when we are decreasing a suffix.  I had
> originally added code for it to somehow cause an increase, but if we push
> the suffix when a new leaf is added we only ever have to handle pulling
> down the suffix with update_suffix so I updated the code to reflect that.
> 
> As far as side effects the only ones I think that will be obvious should be
> the fact that some routes may be able to be found earlier since before we
> relied on resize to update the suffix lengths, and now we are updating them
> before we add or remove the leaf.

Series applied and queued up for -stable, thanks Alex.
