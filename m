From: Ariel Elior <ariele@broadcom.com>
Subject: RE: [PATCH net-next 0/3] bnx2x: minimize RAM usage in kdump
Date: Tue, 25 Feb 2014 16:41:07 +0000
Message-ID: <6AE768456CEC4B4A9B2248CB6B87EB3E1C01B891@SJEXCHMB05.corp.ad.broadcom.com>
References: <1393340666-3539-1-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Yuval Mintz <yuvalmin@broadcom.com>
To: Michal Schmidt <mschmidt@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:13329 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752826AbaBYQlI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 11:41:08 -0500
In-Reply-To: <1393340666-3539-1-git-send-email-mschmidt@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Michal Schmidt [mailto:mschmidt@redhat.com]
> Sent: Tuesday, February 25, 2014 5:04 PM
> To: davem@davemloft.net
> Cc: netdev@vger.kernel.org; Ariel Elior; Dmitry Kravkov; Yuval Mintz
> Subject: [PATCH net-next 0/3] bnx2x: minimize RAM usage in kdump
> 
> kdump kernels usually have only a small amount of memory reserved.
> bnx2x can be memory-hungry. Let's minimize its memory usage when
> running in kdump.
> 
> I detect kdump by looking at the "reset_devices" flag. A couple of
> storage drivers (cciss, hpsa) use it for the same purpose. I am not sure
> this is the best way to solve the problem, but it works.
> 
> Should it be made more generic by, say, looking at the total amount
> of lowmem instead? Not using TPA by default when lowmem is small and/or
> defaulting to fewer queues would help 32bit systems where a driver for
> a multi-function multi-queue NIC can consume a significant amount
> of available memory. Or do we want no such heuristics?
> 
> Is this something to consider doing for other network drivers too?
> 
> Michal Schmidt (3):
>   bnx2x: clamp num_queues to prevent passing a negative value
>   bnx2x: save RAM in kdump kernel by using a single queue
>   bnx2x: save RAM in kdump kernel by disabling TPA
> 
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  | 12 ++++++++----
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |  2 ++
>  2 files changed, 10 insertions(+), 4 deletions(-)
> 
> --
> 1.8.5.3

This series looks good, in the sense that it modifies the driver in a correct way to achieve the intended result (less memory on kdump).
The basic question of testing lowmem vs. reset_devices or perhaps some other parameter still needs to be answered though.
Acked-by: Ariel Elior <ariele@broadcom.com>

Thanks,
Ariel
