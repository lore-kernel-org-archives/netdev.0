From: Andy Zhou <azhou@nicira.com>
Subject: Re: [net-next 03/10] vxlan: Remove vxlan_get_rx_port()
Date: Tue, 22 Jul 2014 20:57:20 -0700
Message-ID: <CACzMAJK_yPod7343tUY=fS2xL=GqBU=0qWpbmHi7U_8rfMnHXw@mail.gmail.com>
References: <1406024393-6778-1-git-send-email-azhou@nicira.com>
	<1406024393-6778-4-git-send-email-azhou@nicira.com>
	<CAKgT0UeRSc3MaZrLmXyx4jPZO+F1hS5imR1TjFkvKp4S8nQmeg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog120.obsmtp.com ([74.125.149.140]:55426 "HELO
	na3sys009aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754861AbaGWD5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 23:57:21 -0400
Received: by mail-oi0-f41.google.com with SMTP id a141so442341oig.28
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 20:57:20 -0700 (PDT)
In-Reply-To: <CAKgT0UeRSc3MaZrLmXyx4jPZO+F1hS5imR1TjFkvKp4S8nQmeg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

You are right.  Thanks for pointing this out. I will swap it in the
next version.

On Tue, Jul 22, 2014 at 7:20 PM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On Tue, Jul 22, 2014 at 3:19 AM, Andy Zhou <azhou@nicira.com> wrote:
>>
>> Instead of specificly calling vxlan_get_rx_port(), Device driver
>> should now call udp_tunnel_get_rx_port() instead.  Making this change
>> to support future NICs and device drivers that may support more
>> UDP tunnel protocol offloads.
>>
>> Signed-off-by: Andy Zhou <azhou@nicira.com>
>> ---
>>  drivers/net/ethernet/emulex/benet/be_main.c      |    2 +-
>>  drivers/net/ethernet/intel/i40e/i40e_main.c      |    2 +-
>>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c   |    2 +-
>>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    2 +-
>>  drivers/net/vxlan.c                              |   26
>> ----------------------
>>  include/net/vxlan.h                              |    7 ------
>>  6 files changed, 4 insertions(+), 37 deletions(-)
>
>
> If I am not mistaken I think this patch is incomplete.  There is nothing
> that is currently initializing the tunnel type for VXLAN until the next
> patch.  As such I believe this patch breaks the functionality.  You might
> want to consider swapping it with patch 4 in order to avoid that.
>
> Thanks,
>
> Alex
