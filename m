From: tedheadster <tedheadster@gmail.com>
Subject: Re: [regression v4.11] 617f01211baf ("8139too: use napi_complete_done()")
Date: Mon, 10 Apr 2017 10:22:05 -0400
Message-ID: <CAP8WD_aos5u90cxS5+fCL9pVziHXV==1b+j2tzwxA5qxe7Ao-w@mail.gmail.com>
References: <20170407181754.GL30290@intel.com> <1491590329.10124.86.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170407.114216.29873489271414092.davem@davemloft.net> <20170408102305.GA4522@electric-eye.fr.zoreil.com>
Reply-To: whiteheadm@acm.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: ville.syrjala@linux.intel.com, David Miller <davem@davemloft.net>,
        eric.dumazet@gmail.com, edumazet@google.com,
        netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:33626 "EHLO
        mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753635AbdDJOWc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 10:22:32 -0400
In-Reply-To: <20170408102305.GA4522@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 8, 2017 at 6:23 AM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> David Miller <davem@davemloft.net> :
> [...]
>> One theory is that the interrupt masking isn't working properly
>> and interrupts are still arriving and hitting the NAPI state even
>> when we are actively polling NAPI.
>>
>> And this problem was masked by the locking done here.
>
> Yes.
>
> Ville, can you rule out irq sharing between the 8139 and some other
> device ? It's a candidate for unexpected interrupt handler invocation
> with older pc, even with properly working hardware.
>

Eric,
  If napi_complete_done() calls could affect drivers on older
hardware, I can test the following:

drivers/net/ethernet/3com/typhoon.c
drivers/net/ethernet/amd/pcnet32.c
drivers/net/ethernet/broadcom/tg3.c
drivers/net/ethernet/dec/tulip/interrupt.c
drivers/net/ethernet/intel/e100.c
drivers/net/ethernet/intel/e1000/e1000_main.c
drivers/net/ethernet/smsc/epic100.c
drivers/net/ethernet/via/via-rhine.c

- Matthew
