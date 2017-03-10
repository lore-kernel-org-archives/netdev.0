From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v3 net-next 1/2] net: Avoid unnessary loop when master_idx
 is invalid in inet_select_addr
Date: Thu, 9 Mar 2017 20:58:46 -0700
Message-ID: <75261fc6-d793-031d-0a8e-bd864469ae27@cumulusnetworks.com>
References: <1489114366-7355-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: fgao@ikuai8.com, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, kaber@trash.net, netdev@vger.kernel.org,
        gfree.wind@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:33450 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751383AbdCJD6u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 22:58:50 -0500
Received: by mail-pg0-f41.google.com with SMTP id 25so34063678pgy.0
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 19:58:49 -0800 (PST)
In-Reply-To: <1489114366-7355-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/9/17 7:52 PM, fgao@ikuai8.com wrote:
> From: Gao Feng <fgao@ikuai8.com>
> 
> When master_idx is invalid, it is zero. It is unnecessary to iterate
> all netdevs. Because l3mdev_master_ifindex_rcu(dev) != master_idx must
> be true.
> Now put this loop into the condition block when master_idx is valid.

you are significantly changing how this loop works, not just the
master_idx == 0 case. Basically, if dev does not have an address, you
are not going to look at the other interfaces.

The
   if (l3mdev_master_ifindex_rcu(dev) != master_idx)

is actually relevant.

If dev is enslaved to an L3 device, only consider devices in that
domain. Conversely, if dev is NOT enslaved to an L3 device, do NOT
consider devices that are enslaved to one. Both of those are equally
important.
