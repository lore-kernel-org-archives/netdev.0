From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCHv2 1/5] sh_eth: add generic wake-on-lan support via magic
 packet
Date: Sun, 25 Dec 2016 00:53:53 +0300
Message-ID: <8339b438-5fb2-6a19-23bd-8ce32e29f30d@cogentembedded.com>
References: <20161212160931.6478-1-niklas.soderlund+renesas@ragnatech.se>
 <20161212160931.6478-2-niklas.soderlund+renesas@ragnatech.se>
 <87e3f9e6-0f5a-986c-772d-006cb25b9fd9@cogentembedded.com>
 <20161219163904.GE21006@bigcity.dyn.berto.se>
 <CAMuHMdXVVS_eLozvDnEz67_Fwg7jGDK0YEGh84rS+EAm4RFnag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms+renesas@verge.net.au>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>,
        =?UTF-8?Q?Niklas_S=c3=b6derlund?= <niklas.soderlund@ragnatech.se>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdXVVS_eLozvDnEz67_Fwg7jGDK0YEGh84rS+EAm4RFnag@mail.gmail.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 12/19/2016 08:11 PM, Geert Uytterhoeven wrote:

>>>> One quirk needed for WoL is that the module clock needs to be prevented
>>>> from being switched off by Runtime PM. To keep the clock alive the
>>>
>>>    I tried to find the code in question and failed, getting muddled in the
>>> RPM maze. Could you point at this code for my education? :-)
>>
>> In my investigation I observed this (simplified) call graph with regards
>> to clocks for suspend:
>>
>> pm_suspend

    There's a long list of the calls skipped here. :-)

>>   pm_clk_suspend
>>     clk_disable
>>       clk_core_disable
>>         cpg_mstp_clock_disable
>>
>> The interesting function here are clk_core_disable(). In that function a
>> 'enable_count' for each clock is decremented and the clock is only
>> turned of if the count reaches zero, hence cpg_mstp_clock_disable() are
>> only called if the counter reaches 0. At runtime the enable_count can be
>> displayed by examining /sys/kernel/debug/clk/clk_summary.

    Well, this is not new to me... it's more interesting how we get there... :-)

[...]
>>>> usage count of the clock. Then when Runtime PM decreases the clock usage
>>>> count it won't reach 0 and be switched off.
>>>
>>>    You mean it does this even though we don't call pr_runtime_put_sync()
>>> as done in sh_eth_close()?
>>
>> Yes.
>>
>> I had a look at the pm_runtime_* functions in include/linux/pm_runtime.h
>> and drivers/base/power/runtime.c and could not find any clock handling.
>> Maybe they only deal with power domains?
>
> There should be a generic way to prevent a device from being suspended.

    Indeed.

> This will make sure the module clock is not disabled, and the power domain
> (if applicable) is not powered down.

    I've just bumped into <linux/pm_wakeirq.h>, it looks promising...

[...]
> Gr{oetje,eeting}s,
>
>                         Geert

MBR, Sergei
