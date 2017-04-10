From: Eric Dumazet <edumazet@google.com>
Subject: Re: [regression v4.11] 617f01211baf ("8139too: use napi_complete_done()")
Date: Mon, 10 Apr 2017 07:55:31 -0700
Message-ID: <CANn89iKK6VpTaPt_Azf+ELEEER9R+RbirKUzyPXqOGje_UbE8Q@mail.gmail.com>
References: <20170407181754.GL30290@intel.com> <1491590329.10124.86.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170407.114216.29873489271414092.davem@davemloft.net> <20170408102305.GA4522@electric-eye.fr.zoreil.com>
 <CAP8WD_aos5u90cxS5+fCL9pVziHXV==1b+j2tzwxA5qxe7Ao-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Francois Romieu <romieu@fr.zoreil.com>,
        ville.syrjala@linux.intel.com, David Miller <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: whiteheadm@acm.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAP8WD_aos5u90cxS5+fCL9pVziHXV==1b+j2tzwxA5qxe7Ao-w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 10, 2017 at 7:22 AM, tedheadster <tedheadster@gmail.com> wrote:
> On Sat, Apr 8, 2017 at 6:23 AM, Francois Romieu <romieu@fr.zoreil.com> wrote:
>> David Miller <davem@davemloft.net> :
>> [...]
>>> One theory is that the interrupt masking isn't working properly
>>> and interrupts are still arriving and hitting the NAPI state even
>>> when we are actively polling NAPI.
>>>
>>> And this problem was masked by the locking done here.
>>
>> Yes.
>>
>> Ville, can you rule out irq sharing between the 8139 and some other
>> device ? It's a candidate for unexpected interrupt handler invocation
>> with older pc, even with properly working hardware.
>>
>
> Eric,
>   If napi_complete_done() calls could affect drivers on older
> hardware, I can test the following:
>
> drivers/net/ethernet/3com/typhoon.c
> drivers/net/ethernet/amd/pcnet32.c
> drivers/net/ethernet/broadcom/tg3.c
> drivers/net/ethernet/dec/tulip/interrupt.c
> drivers/net/ethernet/intel/e100.c
> drivers/net/ethernet/intel/e1000/e1000_main.c
> drivers/net/ethernet/smsc/epic100.c
> drivers/net/ethernet/via/via-rhine.c

That would be great, thanks Matthew.
