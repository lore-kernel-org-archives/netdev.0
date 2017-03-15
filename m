From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH v2 2/2] can: spi: hi311x: Add Holt HI-311x CAN driver
Date: Wed, 15 Mar 2017 08:19:29 +0100
Message-ID: <15211aa1-7396-391d-de15-b10ff3a3382d@grandegger.com>
References: <1484680922-25813-1-git-send-email-akshay.bhat@timesys.com>
 <1484680922-25813-2-git-send-email-akshay.bhat@timesys.com>
 <234d9e75-0083-b8b4-c781-add653fdb550@grandegger.com>
 <b3ebb569-b50c-39ad-dec5-0059fbfba8fb@timesys.com>
 <eb4e0f6f-14de-3369-0d50-7371ae74f4fb@grandegger.com>
 <3dbf8748-9d04-0f21-0e95-448d7a72e7d5@timesys.com>
 <41439729-42d0-d883-2801-2d3607f2aeab@grandegger.com>
 <CANiP4c8WMeT1Cr7WDXew1ne7DFR04oaA8Uch0zvyyOf5yCa37A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Akshay Bhat <akshay.bhat@timesys.com>, mkl@pengutronix.de,
        linux-can@vger.kernel.org, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org
To: Akshay Bhat <nodeax@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANiP4c8WMeT1Cr7WDXew1ne7DFR04oaA8Uch0zvyyOf5yCa37A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Akshay,

Am 15.03.2017 um 05:44 schrieb Akshay Bhat:
> Hi Wolfgang,
>
> On Tue, Mar 14, 2017 at 2:08 PM, Wolfgang Grandegger <wg@grandegger.com> wrote:
> ...snip....
>>> /////disconnect cable
>>>   can0  20000088   [8]  00 00 00 19 00 00 28 00   ERRORFRAME
>>>         protocol-violation{{}{acknowledge-slot}}
>>>         bus-error
>>>         error-counter-tx-rx{{40}{0}}
>>>   can0  20000088   [8]  00 00 00 19 00 00 58 00   ERRORFRAME
>>>         protocol-violation{{}{acknowledge-slot}}
>>>         bus-error
>>>         error-counter-tx-rx{{88}{0}}
>>>   can0  20000088   [8]  00 00 00 19 00 00 80 00   ERRORFRAME
>>>         protocol-violation{{}{acknowledge-slot}}
>>>         bus-error
>>>         error-counter-tx-rx{{128}{0}}
>>
>>
>> TX error warning is missing.
>>
>
> This support was missing in the driver, added in V4 patch.
>
>>>   can0  2000008C   [8]  00 20 00 19 00 00 80 00   ERRORFRAME
>>>         controller-problem{tx-error-passive}
>>>         protocol-violation{{}{acknowledge-slot}}
>>>         bus-error
>>>         error-counter-tx-rx{{128}{0}}
>>
>>
>> Here "tx-error-passiv" is packed with a bus error. What I'm looking for are
>> state change messages similar to:
>>
>>    can0  20000204  [8] 00 08 00 00 00 00 60 00   ERRORFRAME
>>         controller-problem{tx-error-warning}
>>         state-change{tx-error-warning}
>>         error-counter-tx-rx{{96}{0}}
>>    can0  20000204  [8] 00 30 00 00 00 00 80 00   ERRORFRAME
>>         controller-problem{tx-error-passive}
>>         state-change{tx-error-passive}
>>         error-counter-tx-rx{{128}{0}
>>
>> They should always come, even with "berr-reporting off".
>>
>
> HI-3110 has only 1 bus error interrupt. There is no dedicated state
> change interrupts like other controllers.

To double check: Could you please read INTF, ERR and STATF at the 
beginning of the ISR and print it out (using dev_dbg and fiends). Then 
run a test with no cable connected and bus error reporting off.

Wolfgang.
