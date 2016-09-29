From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net v2] tg3: Avoid NULL pointer dereference in tg3_io_error_detected()
Date: Thu, 29 Sep 2016 10:41:53 -0700
Message-ID: <CACKFLi=yE2xGPXud8bLqU9SRZRPAi=oVrvThyBG2g26xxxY0vg@mail.gmail.com>
References: <1475166248-8665-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Siva Reddy Kallam <siva.kallam@broadcom.com>,
        Prashant Sreedharan <prashant@broadcom.com>,
        Michael Chan <mchan@broadcom.com>,
        Netdev <netdev@vger.kernel.org>,
        Milton Miller <miltonm@us.ibm.com>
To: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f175.google.com ([209.85.217.175]:33895 "EHLO
        mail-ua0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934123AbcI2Rlz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 13:41:55 -0400
Received: by mail-ua0-f175.google.com with SMTP id l16so53909864uaa.1
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 10:41:55 -0700 (PDT)
In-Reply-To: <1475166248-8665-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 29, 2016 at 9:24 AM, Guilherme G. Piccoli
<gpiccoli@linux.vnet.ibm.com> wrote:
> From: Milton Miller <miltonm@us.ibm.com>
>
> While the driver is probing the adapter, an error may occur before the
> netdev structure is allocated and attached to pci_dev. In this case,
> not only netdev isn't available, but the tg3 private structure is also
> not available as it is just math from the NULL pointer, so dereferences
> must be skipped.
>
> The following trace is seen when the error is triggered:
>
>   [1.402247] Unable to handle kernel paging request for data at address 0x00001a99
>   [1.402410] Faulting instruction address: 0xc0000000007e33f8
>   [1.402450] Oops: Kernel access of bad area, sig: 11 [#1]
>   [1.402481] SMP NR_CPUS=2048 NUMA PowerNV
>   [1.402513] Modules linked in:
>   [1.402545] CPU: 0 PID: 651 Comm: eehd Not tainted 4.4.0-36-generic #55-Ubuntu
>   [1.402591] task: c000001fe4e42a20 ti: c000001fe4e88000 task.ti: c000001fe4e88000
>   [1.402742] NIP: c0000000007e33f8 LR: c0000000007e3164 CTR: c000000000595ea0
>   [1.402787] REGS: c000001fe4e8b790 TRAP: 0300   Not tainted  (4.4.0-36-generic)
>   [1.402832] MSR: 9000000100009033 <SF,HV,EE,ME,IR,DR,RI,LE>  CR: 28000422  XER: 20000000
>   [1.403058] CFAR: c000000000008468 DAR: 0000000000001a99 DSISR: 42000000 SOFTE: 1
>   GPR00: c0000000007e3164 c000001fe4e8ba10 c0000000015c5e00 0000000000000000
>   GPR04: 0000000000000001 0000000000000000 0000000000000039 0000000000000299
>   GPR08: 0000000000000000 0000000000000001 c000001fe4e88000 0000000000000006
>   GPR12: 0000000000000000 c00000000fb40000 c0000000000e6558 c000003ca1bffd00
>   GPR16: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
>   GPR20: 0000000000000000 0000000000000000 0000000000000000 c000000000d52768
>   GPR24: c000000000d52740 0000000000000100 c000003ca1b52000 0000000000000002
>   GPR28: 0000000000000900 0000000000000000 c00000000152a0c0 c000003ca1b52000
>   [1.404226] NIP [c0000000007e33f8] tg3_io_error_detected+0x308/0x340
>   [1.404265] LR [c0000000007e3164] tg3_io_error_detected+0x74/0x340
>
> This patch avoids the NULL pointer dereference by moving the access after
> the netdev NULL pointer check on tg3_io_error_detected(). Also, we add a
> check for netdev being NULL on tg3_io_resume() [suggested by Michael Chan].
>
> Fixes: 0486a063b1ff ("tg3: prevent ifup/ifdown during PCI error recovery")
> Fixes: dfc8f370316b ("net/tg3: Release IRQs on permanent error")
> Tested-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>
> Signed-off-by: Milton Miller <miltonm@us.ibm.com>
> Signed-off-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>

Acked-by: Michael Chan <michael.chan@broadcom.com>
