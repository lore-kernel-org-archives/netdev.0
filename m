From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH] net: bonding: Fix transmit load balancing in balance-alb
 mode if specified by sysfs
Date: Sat, 9 Sep 2017 14:23:08 +0300
Message-ID: <43356b9d-77e5-4ccb-ee1b-f293d2fb130c@cumulusnetworks.com>
References: <17EC94B0A072C34B8DCF0D30AD16044A0298684C@BPXM09GP.gisp.nec.co.jp>
 <03b61877-053b-2f0e-dc35-8fe31cc90c08@cumulusnetworks.com>
 <CAF2d9jgHLJ28hpiSafL7823-Ga4y8aYZ2t_Sqh7D51VL_DgDww@mail.gmail.com>
 <9ae82441-78da-0056-88c1-2f9d863fb81f@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Kosuke Tatsukawa <tatsu@ab.jp.nec.com>,
        Jay Vosburgh <j.vosburgh@gmail.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Reinis Rozitis <r@roze.lv>
To: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS1?=
         =?UTF-8?B?4KS+4KSwKQ==?= <maheshb@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9ae82441-78da-0056-88c1-2f9d863fb81f@cumulusnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/09/17 13:29, Nikolay Aleksandrov wrote:
> On 09/09/17 02:54, Mahesh Bandewar (महेश बंडेवार) wrote:
>> On Fri, Sep 8, 2017 at 7:30 AM, Nikolay Aleksandrov
>> <nikolay@cumulusnetworks.com> wrote:
>>> On 08/09/17 17:17, Kosuke Tatsukawa wrote:
[snip]
>>>
>> I think the underlying issue is that tlb_dynamic_lb should be set to 1
>> for all modes which was not the case when it was getting initialized
>> only forTLB mode. So from that perspective I prefer Nik's patch with a
>> small variation that guards the case when mode transitions from TLB to
>> ALB. The reason why I like that patch is because it's simple and
>> avoids complications.
> 
> +1, I think this is the most straight-forward solution as well and
> safest for -net
> 
> I will go ahead and submit it in a few minutes.
> 
> Thanks,
>  Nik
> 

Just FYI, since the second fix (tlb_dynamic_lb in TLB = 0 switch to ALB) is identical
to this patch, I'm acking this one and will wait until it's in to submit the default
value fix (if we start in non-TLB mode and switch to TLB we'll get dynamic_lb = 0
currently).

I guess this is the simplest way, I didn't want to alter user-configured value on
mode switch, but it seems better than the alternative especially for -net.
