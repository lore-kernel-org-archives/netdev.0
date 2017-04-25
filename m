From: "Lino Sanfilippo" <LinoSanfilippo@gmx.de>
Subject: Aw: Re: [Intel-wired-lan] [PATCH] ixgbe: initialize u64_stats_sync
 structures early at ixgbe_probe
Date: Tue, 25 Apr 2017 17:39:35 +0200
Message-ID: <trinity-a348af9b-9ef5-47a9-a14e-94265c880cf1-1493134775614@3capp-gmx-bs78>
References: <1480909244-16460-1-git-send-email-liwei.song@windriver.com>
 <EF50CC0C76A53A44BAD798C58E0A157E50B87CBB@ORSMSX103.amr.corp.intel.com>,
 <CAKgT0UeTdY9j1qDHP=DscgAZF2pPFCb+=ACySqKBK+UuBsaNBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Singh, Krishneil K" <krishneil.k.singh@intel.com>,
        "Song, Liwei (Wind River)" <liwei.song@windriver.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Alexander Duyck" <alexander.duyck@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKgT0UeTdY9j1qDHP=DscgAZF2pPFCb+=ACySqKBK+UuBsaNBA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> This patch doesn't look right to me. I would suggest rejecting it.
> 
> The call to initialize the stats should be done when the ring is
> allocated, not in ixgbe_probe(). This should probably be done in
> ixgbe_alloc_q_vector() instead.
> 

AFAICS ixgbe_alloc_q_vector() is also called in probe() (by ixgbe_init_interrupt_scheme()).
Furthermore it is also called in resume() which would lead to multiple initialization of
the u64_stats_sync in case of resume.

IMHO the u64_stats_sync variables have to be initialized before register_netdev() is called
since this is the point from which userspace can call ixgbe_get_stats64(). I would say the
best place to do so is the probe() function as it is done in this patch.

Just my 2 cents.

Regards,
Lino
