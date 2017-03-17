From: Akshay Bhat <akshay.bhat-jEh4hwF5bVhBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH v2 2/2] can: spi: hi311x: Add Holt HI-311x CAN driver
Date: Fri, 17 Mar 2017 14:28:42 -0400
Message-ID: <ff5d44d1-3bfe-8dae-2aaa-561ab0cb989c@timesys.com>
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
 <69173747-cc2e-55f7-acad-4b5ba2a22863@timesys.com>
 <d5182e77-c243-1980-4cb6-39cd95075f4f@grandegger.com>
 <0362316b-ef76-1733-dbfc-8b644f758db9@timesys.com>
 <7730cff6-6e85-c98d-0315-bd3888d3aeb1@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
        Akshay Bhat <nodeax-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <7730cff6-6e85-c98d-0315-bd3888d3aeb1-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Wolfgang,

On 03/17/2017 01:04 PM, Wolfgang Grandegger wrote:
> 
> Hm, that's unusual. Cable disconnected and then send a message:
> 
> $ grep /proc/interrupts; sleep 10; /proc/interrupts
> 
> should make things clear. But maybe it's a clever chip and it does stop
> sending error messages if the error counter does not change any more.
> After bus-off, the chip is quiet, of course. Should have a closer look
> to the CAN standard.
>

The interrupt count does not increment after device reaches
tx-error-passive (with cable disconnected).

# while true; do grep -i hi3110 /proc/interrupts; sleep 10; done &
[1] 793
#
111:          0          0  gpio-mxc  12 Edge      hi3110
# candump -t d -e any,0:0,#FFFFFFF &
[2] 798
# cansend can0 123#
#
 (000.000000)  can0  20000004   [8]  00 08 00 00 00 00 60 00   ERRORFRAME
	controller-problem{tx-error-warning}
	error-counter-tx-rx{{96}{0}}
 (000.002122)  can0  20000004   [8]  00 20 00 00 00 00 80 00   ERRORFRAME
	controller-problem{tx-error-passive}
	error-counter-tx-rx{{128}{0}}
111:         10          0  gpio-mxc  12 Edge      hi3110
111:         10          0  gpio-mxc  12 Edge      hi3110
111:         10          0  gpio-mxc  12 Edge      hi3110

>>> So far using NAPI was mandatory. There is the problem of out-of-order
>>> message reception if handled in the isr on multi processor systems.
>>> Marc, what is the current policy?
>>>
>>
>> Since this is a SPI based CAN, I am wary for any additional latencies
>> NAPI might introduce. The RX handling is being done at the very
>> beginning of the ISR for this reason.
>>
>> Can we go ahead with the existing implementation and re-visit this at a
>> later time?
> 
> Likely yes, as Marc has already reviewed the driver once.
> 

Thanks, I will go ahead and submit v4 patch.

> BTW: what system board/processor are you using?
> 

It is a custom board using Phytec phyFLEX-i.MX6 Dual SOM.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
