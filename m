From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] i40e: Invoke softirqs after napi_reschedule
Date: Thu, 12 Jan 2017 17:15:30 -0800
Message-ID: <1484270130.13165.15.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170113010414.22708-1-bpoirier@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: Benjamin Poirier <bpoirier@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33176 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750874AbdAMBPd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 20:15:33 -0500
Received: by mail-pf0-f193.google.com with SMTP id 127so5699736pfg.0
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 17:15:32 -0800 (PST)
In-Reply-To: <20170113010414.22708-1-bpoirier@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-01-12 at 17:04 -0800, Benjamin Poirier wrote:
> The following message is logged from time to time when using i40e:
> NOHZ: local_softirq_pending 08
> 
> i40e may schedule napi from a workqueue. Afterwards, softirqs are not run
> in a deterministic time frame. The problem is the same as what was
> described in commit ec13ee80145c ("virtio_net: invoke softirqs after
> __napi_schedule") and this patch applies the same fix to i40e.

Yes, I believe mlx4 has a similar problem in mlx4_en_recover_from_oom()
