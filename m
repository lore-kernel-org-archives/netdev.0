From: Enric Balletbo i Serra <enric.balletbo@collabora.com>
Subject: Re: [PATCH] cfg80211: Be able to set bss expire time at config stage.
Date: Mon, 22 May 2017 18:59:16 +0200
Message-ID: <aad376ad-ebe2-ec3a-15c9-187f63594083@collabora.com>
References: <20170522160946.2057-1-enric.balletbo@collabora.com>
 <1495470111.25557.9.camel@redhat.com>
 <1495470254.26008.3.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Dmitry Shmidt <dimitrysh@google.com>,
        helmut.schaa@googlemail.com
To: Johannes Berg <johannes@sipsolutions.net>,
        Dan Williams <dcbw@redhat.com>,
        "David S . Miller" <davem@davemloft.net>,
        linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1495470254.26008.3.camel@sipsolutions.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 22/05/17 18:24, Johannes Berg wrote:
> 
>> Couldn't userspace just look at NL80211_BSS_SEEN_MS_AGO to filter and
>> create its own list?  Given that the kernel provides the information
>> userspace needs to figure out the age of a particular BSS, it doesn't
>> seem like there needs to be a kernel tunable for this.  Userspace can
>> already avoid stale results.
> 
> Yeah, I agree. It can also ask for a flush, so that old results are
> gone by the time the next scan returns. We don't have a flush operation
> without requesting a new scan, but I guess that could be added.
> 

Ok, guess I understand what you're saying. Thanks for pointing me in the right
direction.

>> Also, different runtime situations might want different result ages,
>> which wouldn't be possible if the kernel had a hardcoded maximum. 
>> Furthermore, different userspace apps might be reading the same scan
>> list, and they might have different ideas about staleness.
>>
>> Or perhaps I misunderstand the problem, which could well be the case.
> 
> No, I think this is perfectly right - userspace should be able to deal
> with this given the tools we gave it, or if not, we should probably
> just give it more tools instead of hardcoding the kernel configuration.
> 
> This value really just kinda needed to be an upper bound so that we
> don't start expiring entries while we're still scanning.
> 
> johannes
> 
