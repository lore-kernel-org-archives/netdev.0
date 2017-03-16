From: Akshay Bhat <akshay.bhat@timesys.com>
Subject: Re: [PATCH v2 2/2] can: spi: hi311x: Add Holt HI-311x CAN driver
Date: Thu, 16 Mar 2017 18:29:38 -0400
Message-ID: <69173747-cc2e-55f7-acad-4b5ba2a22863@timesys.com>
References: <1484680922-25813-1-git-send-email-akshay.bhat@timesys.com>
 <1484680922-25813-2-git-send-email-akshay.bhat@timesys.com>
 <234d9e75-0083-b8b4-c781-add653fdb550@grandegger.com>
 <b3ebb569-b50c-39ad-dec5-0059fbfba8fb@timesys.com>
 <eb4e0f6f-14de-3369-0d50-7371ae74f4fb@grandegger.com>
 <3dbf8748-9d04-0f21-0e95-448d7a72e7d5@timesys.com>
 <41439729-42d0-d883-2801-2d3607f2aeab@grandegger.com>
 <CANiP4c8WMeT1Cr7WDXew1ne7DFR04oaA8Uch0zvyyOf5yCa37A@mail.gmail.com>
 <3dba0948-ffcb-8e80-fb32-62bb0aca6627@grandegger.com>
 <54d9a104-8ed1-4bb3-666e-042d3781dbfb@timesys.com>
 <006d9e14-47bf-1add-97c3-24098b43267f@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: mkl@pengutronix.de, linux-can@vger.kernel.org,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>,
        Akshay Bhat <nodeax@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <006d9e14-47bf-1add-97c3-24098b43267f@grandegger.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Wolfgang,

On 03/16/2017 04:02 PM, Wolfgang Grandegger wrote:
> 
> Looks much better now! There are message for state changes to error
> warning and passive. Just the following message is not correct:
> 
>  (000.200824)  can0  20000004   [8]  00 40 00 00 00 00 5F 19   ERRORFRAME
>     controller-problem{}
>     error-counter-tx-rx{{95}{25}}
> 
> Sorry, forgot to mention... the function can_change_state() [1]
> should be used for that purpose, if possible. It fixes the issue
> above as well.
> 

The updated driver (the one used to create the above log) is using
can_change_state() function. data[1] 40 corresponds to
CAN_ERR_CRTL_ACTIVE, so looks correct? Could it be that the can-utils I
am using is old and not reporting state change?

Tentative v4 driver for reference:
http://pastebin.com/4xFVL1Sj

>> berr-reporting off case:
>> http://pastebin.com/fUn3j7qU
> 
> Ditto.
> 
> I just had another look to the manual and there is this undocumented
> STATFE register at offset 0x1E. It's mentioned in some other parts of
> the doc as interrupt enable register for STATF events. I would assume
> the same bit layout than STATF. If you set bit 2 (BUSOFF), 3 (ERRP)
> and 4 (ERRW), you may get interrupts. It's worth a try, I think. If
> it works, it's the much better solution.
> 

The HI-311x has a INT pin and a STAT pin. The hardware I have has only
the INT pin connected to the processor. If the STAT pin was also
connected, then like you mentioned it could be a much better solution to
use STAT for state changes.

Enabling BUSOFF/ERRP/ERRW bits in STATFE did not generate any interrupts
on the INT pin. Should we make it a requirement that both INT and STAT
pins need to be connected in hardware for the driver to do the error
reporting?

Thanks,
Akshay

> Wolfgang.
> 
> [1] http://lxr.free-electrons.com/ident?i=can_change_state
> 
> Wolfgang.
> 
