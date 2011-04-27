From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: rtl8169 related kernel splat in 2.6.38.4
Date: Wed, 27 Apr 2011 22:34:55 +0200
Message-ID: <20110427203455.GA19708@electric-eye.fr.zoreil.com>
References: <4DB7413A.1020208@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:59813 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756789Ab1D0Unf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 16:43:35 -0400
Content-Disposition: inline
In-Reply-To: <4DB7413A.1020208@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear <greearb@candelatech.com> :
[...]
> WARNING: at /home/greearb/git/linux-2.6.dev.38.y/kernel/timer.c:983 del_timer_sync+0x25/0x37()
[...]
>  [<c043094b>] ? warn_slowpath_common+0x65/0x7a
>  [<c04398a0>] ? del_timer_sync+0x25/0x37
>  [<c043096f>] ? warn_slowpath_null+0xf/0x13
>  [<c04398a0>] ? del_timer_sync+0x25/0x37
>  [<c06e94f3>] ? linkwatch_schedule_work+0x68/0x83
>  [<c06e95b6>] ? linkwatch_fire_event+0xa8/0xad
>  [<c06ef193>] ? netif_carrier_on+0x23/0x34
>  [<f8af1b32>] ? __rtl8169_check_link_status+0x4f/0xaf [r8169]

linkwatch_schedule_work
-> cancel_delayed_work
   -> del_timer_sync
      -> *466bd3030973910118ca601da8072be97a1e2209 was here*

At first sight it should happen in -git too. I'll search a fix
back home.

-- 
Ueimor
