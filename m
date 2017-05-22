From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] cfg80211: Be able to set bss expire time at config
 stage.
Date: Mon, 22 May 2017 18:24:14 +0200
Message-ID: <1495470254.26008.3.camel@sipsolutions.net>
References: <20170522160946.2057-1-enric.balletbo@collabora.com>
         <1495470111.25557.9.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Dmitry Shmidt <dimitrysh@google.com>,
        helmut.schaa@googlemail.com
To: Dan Williams <dcbw@redhat.com>,
        Enric Balletbo i Serra <enric.balletbo@collabora.com>,
        "David S . Miller" <davem@davemloft.net>,
        linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1495470111.25557.9.camel@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Couldn't userspace just look at NL80211_BSS_SEEN_MS_AGO to filter and
> create its own list?  Given that the kernel provides the information
> userspace needs to figure out the age of a particular BSS, it doesn't
> seem like there needs to be a kernel tunable for this.  Userspace can
> already avoid stale results.

Yeah, I agree. It can also ask for a flush, so that old results are
gone by the time the next scan returns. We don't have a flush operation
without requesting a new scan, but I guess that could be added.

> Also, different runtime situations might want different result ages,
> which wouldn't be possible if the kernel had a hardcoded maximum. 
> Furthermore, different userspace apps might be reading the same scan
> list, and they might have different ideas about staleness.
> 
> Or perhaps I misunderstand the problem, which could well be the case.

No, I think this is perfectly right - userspace should be able to deal
with this given the tools we gave it, or if not, we should probably
just give it more tools instead of hardcoding the kernel configuration.

This value really just kinda needed to be an upper bound so that we
don't start expiring entries while we're still scanning.

johannes
