From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Avoid in6_addr redefinition
Date: Wed, 18 Jan 2017 21:40:12 -0500 (EST)
Message-ID: <20170118.214012.2158405175540797294.davem@davemloft.net>
References: <1484792716-111108-1-git-send-email-zhengrq.fnst@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thomas.petazzoni@free-electrons.com,
        maxin.john@intel.com
To: zhengrq.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46724 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751699AbdASCkO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 21:40:14 -0500
In-Reply-To: <1484792716-111108-1-git-send-email-zhengrq.fnst@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zheng Ruoqin <zhengrq.fnst@cn.fujitsu.com>
Date: Thu, 19 Jan 2017 10:25:16 +0800

> Due to both <netinet/in.h> and <linux/in6.h> being included, the 
> in6_addr is being redefined: once from the C library headers and once
> from the kernel headers. This causes some build failures with for 
> example the musl C library.
> 
> In order to fix this, use just the C library header <netinet/in.h>.
> Original patch taken from
> http://git.alpinelinux.org/cgit/aports/tree/main/iproute2/musl-fixes.patch.
> 
> (Refreshed the patch for 4.9 release)
> 
> Upstream-Status: Pending
> 
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> Signed-off-by: Maxin B. John <maxin.john@intel.com>
> Signed-off-by: Zheng Ruoqin <zhengrq.fnst@cn.fujitsu.com>

We have multiple definition avoidance using CPP tests, which works in
concert with GLIBC headers, that is supposed to avoid this properly.
