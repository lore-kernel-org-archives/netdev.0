From: Sudeep Holla <sudeep.holla@arm.com>
Subject: Re: [PATCH] net: sky2: Fix shutdown crash
Date: Thu, 17 Nov 2016 16:14:10 +0000
Message-ID: <52ae014e-573a-2cb7-cb9c-a2d604bda97d@arm.com>
References: <1479395665-27784-1-git-send-email-jeremy.linton@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sudeep Holla <sudeep.holla@arm.com>, mlindner@marvell.com,
        stephen@networkplumber.org
To: Jeremy Linton <jeremy.linton@arm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:57182 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932461AbcKQRcU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Nov 2016 12:32:20 -0500
In-Reply-To: <1479395665-27784-1-git-send-email-jeremy.linton@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 17/11/16 15:14, Jeremy Linton wrote:
> The sky2 frequently crashes during machine shutdown with:
>
> sky2_get_stats+0x60/0x3d8 [sky2]
> dev_get_stats+0x68/0xd8
> rtnl_fill_stats+0x54/0x140
> rtnl_fill_ifinfo+0x46c/0xc68
> rtmsg_ifinfo_build_skb+0x7c/0xf0
> rtmsg_ifinfo.part.22+0x3c/0x70
> rtmsg_ifinfo+0x50/0x5c
> netdev_state_change+0x4c/0x58
> linkwatch_do_dev+0x50/0x88
> __linkwatch_run_queue+0x104/0x1a4
> linkwatch_event+0x30/0x3c
> process_one_work+0x140/0x3e0
> worker_thread+0x60/0x44c
> kthread+0xdc/0xf0
> ret_from_fork+0x10/0x50
>
> This is caused by the sky2 being called after it has been shutdown.
> A previous thread about this can be found here:
>
> https://lkml.org/lkml/2016/4/12/410
>
> An alternative fix is to assure that IFF_UP gets cleared by
> calling dev_close() during shutdown. This is similar to what the
> bnx2/tg3/xgene and maybe others are doing to assure that the driver
> isn't being called following _shutdown().
>
> Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>

Since this issue has been very random and on/off recently, it's quite
hard to test this and confirm. However I did around 20 reboot/shutdown
and could not reproduce the issue after applying this patch. So,

Tested-by: Sudeep Holla <sudeep.holla@arm.com>

-- 
Regards,
Sudeep
