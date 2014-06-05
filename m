From: Balakumaran Kannan <kumaran.4353@gmail.com>
Subject: Re: bnx2x: [bnx2x_release_hw_lock:2226(eth3)]lock_status 0x0
 resource_bit 0x1. Unlock was called but lock wasn't taken!
Date: Thu, 5 Jun 2014 16:24:13 +0530
Message-ID: <CAHPKR9J2FsGUC7kQU2WUMXOhzz0nWLwGn_KbOOp2YbjXOsFAOg@mail.gmail.com>
References: <1C24E2A22F3B0C4CAC3C670E0EF37E72063072C6@G6W2489.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Arankal, Nagaraj P" <nagaraj.p.arankal@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:62023 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125AbaFEKyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 06:54:15 -0400
Received: by mail-wg0-f45.google.com with SMTP id m15so859535wgh.4
        for <netdev@vger.kernel.org>; Thu, 05 Jun 2014 03:54:14 -0700 (PDT)
In-Reply-To: <1C24E2A22F3B0C4CAC3C670E0EF37E72063072C6@G6W2489.americas.hpqcorp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arankal,

'bnx2x_acquire_hw_lock' defined in
'drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c' file could fail on
multiple reasons. So it is mandatory to check the return value of that
function.

But I can see multiple functions call 'bnx2x_acquire_hw_lock' and
proceed without checking the return value in the same file. It seems
like a bug.

Regards,
K.Balakumaran

On Thu, Jun 5, 2014 at 3:44 PM, Arankal, Nagaraj P
<nagaraj.p.arankal@hp.com> wrote:
> Hi,
> While executing some functional tests on one of my Server containing bnx2x card, I have observed following messages in /var/log/kern.log
>
>
> root@dl380g8-2x:/var/log# cat /var/log/kern.log
> May 14 06:56:55 dl380g8-2x kernel: [59572.519249] bnx2x: [bnx2x_acquire_hw_lock:2192(eth3)]Timeout
> May 14 06:56:55 dl380g8-2x kernel: [59572.519260] bnx2x: [bnx2x_release_hw_lock:2226(eth3)]lock_status 0x0 resource_bit 0x1. Unlock was called but lock wasn't taken!
> May 14 07:21:11 dl380g8-2x kernel: [61028.418935] bnx2x: [bnx2x_acquire_hw_lock:2192(eth3)]Timeout
> May 14 07:21:11 dl380g8-2x kernel: [61028.418946] bnx2x: [bnx2x_release_hw_lock:2226(eth3)]lock_status 0x0 resource_bit 0x1. Unlock was called but lock wasn't taken!
> May 14 08:42:32 dl380g8-2x kernel: [65906.724350] bnx2x: [bnx2x_acquire_hw_lock:2192(eth3)]Timeout
> May 14 08:42:32 dl380g8-2x kernel: [65906.724361] bnx2x: [bnx2x_release_hw_lock:2226(eth3)]lock_status 0x0 resource_bit 0x1. Unlock was called but lock wasn't taken!
> May 14 09:37:16 dl380g8-2x kernel: [69188.417427] bnx2x: [bnx2x_acquire_hw_lock:2192(eth3)]Timeout
> May 14 09:37:16 dl380g8-2x kernel: [69188.417438] bnx2x: [bnx2x_release_hw_lock:2226(eth3)]lock_status 0x0 resource_bit 0x1. Unlock was called but lock wasn't taken!
> May 14 09:55:19 dl380g8-2x kernel: [70270.645449] bnx2x: [bnx2x_acquire_hw_lock:2192(eth3)]Timeout
> May 14 09:55:19 dl380g8-2x kernel: [70270.645460] bnx2x: [bnx2x_release_hw_lock:2226(eth3)]lock_status 0x0 resource_bit 0x1. Unlock was called but lock wasn't taken!
> May 14 12:41:23 dl380g8-2x kernel: [80229.646043] bnx2x: [bnx2x_acquire_hw_lock:2192(eth3)]Timeout
> May 14 12:41:23 dl380g8-2x kernel: [80229.646055] bnx2x: [bnx2x_release_hw_lock:2226(eth3)]lock_status 0x0 resource_bit 0x1. Unlock was called but lock wasn't taken!
> May 14 14:45:01 dl380g8-2x kernel: [87643.062018] bnx2x: [bnx2x_acquire_hw_lock:2192(eth3)]Timeout
> May 14 14:45:01 dl380g8-2x kernel: [87643.062029] bnx2x: [bnx2x_release_hw_lock:2226(eth3)]lock_status 0x0 resource_bit 0x1. Unlock was called but lock wasn't taken!
> May 14 15:12:15 dl380g8-2x kernel: [89276.234304] bnx2x: [bnx2x_acquire_hw_lock:2192(eth3)]Timeout
> May 14 15:12:15 dl380g8-2x kernel: [89276.234315] bnx2x: [bnx2x_release_hw_lock:2226(eth3)]lock_status 0x0 resource_bit 0x1. Unlock was called but lock wasn't taken!
> root@dl380g8-2x:/var/log#
>
>
> Any idea why?
>
> Kernel version : 3.6.26
> Bnx2x driver version : 1.78.80
>
> Thanks,
> Nagaraj
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
