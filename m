From: Ben Greear <greearb@candelatech.com>
Subject: Re: kmemleak reports in kernel 3.9.5+
Date: Mon, 17 Jun 2013 15:45:38 -0700
Message-ID: <51BF9192.2050702@candelatech.com>
References: <51B61982.2050903@candelatech.com> <CAHkRjk5SDCbqr0Br24YQuHr=j7DmnpYk9CShrz1qiuYff7+qAw@mail.gmail.com> <51B78009.2060808@candelatech.com> <51B7C09D.9020402@candelatech.com> <20130613155040.GE6530@darko.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130613155040.GE6530@darko.cambridge.arm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/13/2013 08:50 AM, Catalin Marinas wrote:
> On Wed, Jun 12, 2013 at 01:28:13AM +0100, Ben Greear wrote:
>> On 06/11/2013 12:52 PM, Ben Greear wrote:
>>> On 06/10/2013 03:32 PM, Catalin Marinas wrote:
>>>> On 10 June 2013 19:22, Ben Greear <greearb@candelatech.com> wrote:
>>>>> We had a system go OOM while doing lots of wireless
>>>>> stations.  (System had 8GB of RAM, so I suspect a leak).
>>>>>
>>>>> I enabled kmemleak in a 3.9.5 (plus some local patches) and
>>>>> I see the entries below.  Any idea if these are real or not?
>>
>> Most of this went away when I disabled SLUB debugging and other
>> kernel hacking options.  The wifi cfg80211_inform_bss_frame
>> remains, however.  I'll go dig some more on that tomorrow...didn't
>> see anything obvious at first glance.
>>
>> But, perhaps there could be some improvements to
>> kmemleak to make it deal better with the various kernel
>> debugging features?
>
> That's unrelated to the debugging features. Kmemleak cannot find
> pointers to the allocated objects. They could be real leaks or it simply
> doesn't scan the right memory where such pointers are stored. The debug
> objects are stored in a list with the head as static memory, so it
> should be scanned.

I re-ran a similar test just now, but I had added an explicit reference
for each of the items that I know this test causes to leak (I add them
to a global list.)

This means that memleak would no longer show them as leaked, and that
also cleaned up all of the strange leaks reported before.

So, I think kmemleak is at least mostly working properly, even with lots
of debugging options.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
