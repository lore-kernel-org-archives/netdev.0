From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] genetlink: fix unsigned int comparison with less than zero
Date: Sat, 12 Nov 2016 21:25:05 -0800
Message-ID: <CAM_iQpUw-PYmksL2StciJiM-8C+y3w9T_Vo4=pVKnjQzTwKvLg@mail.gmail.com>
References: <20161110155758.26996-1-colin.king@canonical.com>
 <CAM_iQpW=q4nm97dNouSL19Cr2cEWT9xQHXAm4CNJk=AY8z_2MA@mail.gmail.com> <1478986636.4226.4.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Colin King <colin.king@canonical.com>,
        "David S . Miller" <davem@davemloft.net>,
        pravin shelar <pshelar@ovn.org>,
        Wei Yongjun <weiyongjun1@huawei.com>,
        Florian Westphal <fw@strlen.de>,
        Tycho Andersen <tycho.andersen@canonical.com>,
        Tom Herbert <tom@herbertland.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478986636.4226.4.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 12, 2016 at 1:37 PM, Johannes Berg
<johannes@sipsolutions.net> wrote:
> On Thu, 2016-11-10 at 09:11 -0800, Cong Wang wrote:
>> On Thu, Nov 10, 2016 at 7:57 AM, Colin King <colin.king@canonical.com
>> > wrote:
>> >
>> > From: Colin Ian King <colin.king@canonical.com>
>> >
>> > family->id is unsigned, so the less than zero check for
>> > failure return from idr_alloc is never true and so the error exit
>> > is never handled.  Instead, assign err and check if this is less
>> > than zero since this is a signed integer.
>>
>> Why family->id can't be just signed int? For me it should be.
>
> I suppose it could be, since family IDs are allocated in a 16-bit range
> anyway. But family IDs can also never actually be negative, so having
> an unsigned int in the struct makes sense too.

All idr_* API's accept int, rather than unsigned int. This is my point.
