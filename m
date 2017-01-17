From: David Miller <davem@davemloft.net>
Subject: Re: Kernel 4.6.7-rt14 kernel workqueue lockup - rtnl deadlock plus
 syscall endless loop
Date: Tue, 17 Jan 2017 14:05:52 -0500 (EST)
Message-ID: <20170117.140552.539738967862859087.davem@davemloft.net>
References: <AM5PR0701MB187338B2418A19E1B4B55C98A07C0@AM5PR0701MB1873.eurprd07.prod.outlook.com>
        <20170117.125748.122599514616047216.davem@davemloft.net>
        <AM5PR0701MB1873F82D61AF17A09F2B0E26A07C0@AM5PR0701MB1873.eurprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: EladN@gilat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41416 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750888AbdAQTFz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 14:05:55 -0500
In-Reply-To: <AM5PR0701MB1873F82D61AF17A09F2B0E26A07C0@AM5PR0701MB1873.eurprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Nachman <EladN@gilat.com>
Date: Tue, 17 Jan 2017 18:15:19 +0000

> Any thought about limiting the amount of busy polling?  Say if more
> than X polls are done within a jiffy, then at least for preemptable
> kernels you can sleep for a jiffy inside the syscall to yield the
> CPU for a while?

We cannot yield there, because we must return immediately from this
context in order to drop the sysctl locks and references.
