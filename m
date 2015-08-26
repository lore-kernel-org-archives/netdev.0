From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: xgene: fix: Oops in linkwatch_fire_event
Date: Tue, 25 Aug 2015 17:06:11 -0700 (PDT)
Message-ID: <20150825.170611.202935268032680894.davem@davemloft.net>
References: <1440540183-11006-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dnelson@redhat.com,
	linux-arm-kernel@lists.infradead.org, patches@apm.com
To: isubramanian@apm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60584 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932899AbbHZAGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 20:06:11 -0400
In-Reply-To: <1440540183-11006-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Iyappan Subramanian <isubramanian@apm.com>
Date: Tue, 25 Aug 2015 15:03:03 -0700

> [ 1065.801569] Internal error: Oops: 96000006 [#1] SMP
> ...
> [ 1065.866655] Hardware name: AppliedMicro Mustang/Mustang, BIOS 1.1.0 Apr 22 2015
> [ 1065.873937] Workqueue: events_power_efficient phy_state_machine
> [ 1065.879837] task: fffffe01de105e80 ti: fffffe00bcf18000 task.ti: fffffe00bcf18000
> [ 1065.887288] PC is at linkwatch_fire_event+0xac/0xc0
> [ 1065.892141] LR is at linkwatch_fire_event+0xa0/0xc0
> [ 1065.896995] pc : [<fffffe000060284c>] lr : [<fffffe0000602840>] pstate: 200001c5
> [ 1065.904356] sp : fffffe00bcf1bd00
> ...
> [ 1066.196813] Call Trace:
> [ 1066.199248] [<fffffe000060284c>] linkwatch_fire_event+0xac/0xc0
> [ 1066.205140] [<fffffe000061167c>] netif_carrier_off+0x54/0x64
> [ 1066.210773] [<fffffe00004f1654>] phy_state_machine+0x120/0x3bc
> [ 1066.216578] [<fffffe00000d8d10>] process_one_work+0x15c/0x3a8
> [ 1066.222296] [<fffffe00000d9090>] worker_thread+0x134/0x470
> [ 1066.227757] [<fffffe00000df014>] kthread+0xe0/0xf8
> [ 1066.232525] Code: 97f65ee9 f9420660 d538d082 8b000042 (885f7c40)
> 
> The fix is to call phy_disconnect() from xgene_enet_mdio_remove,
> which in turn call cancel_delayed_work_sync().
> 
> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>

Applied, thanks.
