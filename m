From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: tehuti: don't process data if it has not been
 copied from userspace
Date: Wed, 19 Jul 2017 22:49:01 -0700 (PDT)
Message-ID: <20170719.224901.2173661512386984465.davem@davemloft.net>
References: <20170719174659.22646-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52436 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754629AbdGTFtC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 01:49:02 -0400
In-Reply-To: <20170719174659.22646-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin King <colin.king@canonical.com>
Date: Wed, 19 Jul 2017 18:46:59 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> The array data is only populated with valid information from userspace
> if cmd != SIOCDEVPRIVATE, other cases the array contains garbage on
> the stack. The subsequent switch statement acts on a subcommand in
> data[0] which could be any garbage value if cmd is SIOCDEVPRIVATE which
> seems incorrect to me.  Instead, just return EOPNOTSUPP for the case
> where cmd == SIOCDEVPRIVATE to avoid this issue.
> 
> As a side note, I suspect that the original intention of the code
> was for this ioctl to work just for cmd == SIOCDEVPRIVATE (and the
> current logic is reversed). However, I don't wont to change the current
> semantics in case any userspace code relies on this existing behaviour.
> 
> Detected by CoverityScan, CID#139647 ("Uninitialized scalar variable")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Yeah this is the safest change for now, applied.

Francois added the register address range checking a year after the
driver was added, so maybe someone used this facility.

It should have been done via ethtool getregs...
