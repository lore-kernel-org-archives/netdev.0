From: Arend Van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: wl1251 & mac address & calibration data
Date: Sun, 18 Dec 2016 11:49:53 +0100
Message-ID: <68166247-bcd3-f598-7f9e-2139e732233e@broadcom.com>
References: <201611111820.52072@pali>
 <CAB=NE6VHF+U7DzapENvLMKtN4Dgi9J0qMoeUJ8o4vSwc2-rRFQ@mail.gmail.com>
 <07be7fc8-6c7f-6e03-379d-fa781b248259@monom.org> <201612161140.27241@pali>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>,
        Tom Gundersen <teg@jklm.no>,
        Johannes Berg <johannes@sipsolutions.net>,
        Ming Lei <ming.lei@canonical.com>,
        Mimi Zohar <zohar@linux.vnet.ibm.com>,
        Bjorn Andersson <bjorn.andersson@linaro.org>,
        =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Sebastian Reichel <sre@kernel.org>,
        Pavel Machek <pavel@ucw.cz>,
        Michal Kazior <michal.kazior@tieto.com>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Tony Lindgren <tony@atomide.com>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        David Woodhouse <dwmw2@infradead.org>,
        Takashi I
To: =?UTF-8?Q?Pali_Roh=c3=a1r?= <pali.rohar@gmail.com>,
        Daniel Wagner <wagi@monom.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201612161140.27241@pali>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-12-2016 11:40, Pali Rohár wrote:
> On Friday 16 December 2016 08:25:44 Daniel Wagner wrote:
>> On 12/16/2016 03:03 AM, Luis R. Rodriguez wrote:
>>> For the new API a solution for "fallback mechanisms" should be
>>> clean though and I am looking to stay as far as possible from the
>>> existing mess. A solution to help both the old API and new API is
>>> possible for the "fallback mechanism" though -- but for that I can
>>> only refer you at this point to some of Daniel Wagner and Tom
>>> Gunderson's firmwared deamon prospect. It should help pave the way
>>> for a clean solution and help address other stupid issues.
>>
>> The firmwared project is hosted here
>>
>> https://github.com/teg/firmwared
>>
>> As Luis pointed out, firmwared relies on
>> FW_LOADER_USER_HELPER_FALLBACK, which is not enabled by default.
> 
> I know. But it does not mean that I cannot enable this option at kernel 
> compile time.
> 
> Bigger problem is that currently request_firmware() first try to load 
> firmware directly from VFS and after that (if fails) fallback to user 
> helper.
> 
> So I would need to extend kernel firmware code with new function (or 
> flag) to not use VFS and try only user mode helper.

Why do you need the user-mode helper anyway. This is all static data,
right? So why not cook up a firmware file in user-space once and put it
in /lib/firmware for the driver to request directly. Seems a bit
overkill to have a {e,}udev or whatever daemon running if the result is
always the same. Just my 2 cents.

Regards,
Arend
