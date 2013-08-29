From: David Miller <davem@davemloft.net>
Subject: Re: [-next] openvswitch BUILD_BUG_ON failed
Date: Thu, 29 Aug 2013 18:10:01 -0400 (EDT)
Message-ID: <20130829.181001.145658561677052552.davem@davemloft.net>
References: <CAMuHMdVG9FmZNayrf7HMz4kC4X5QELeXUFjjzpAM80ND_QOm8A@mail.gmail.com>
	<CAEP_g=-XvRiHPzSAp2rgC9Hxdd+pGEHvSTEJ1A1SkWnk1-6xZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: geert@linux-m68k.org, azhou@nicira.com, dev@openvswitch.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-next@vger.kernel.org
To: jesse@nicira.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <CAEP_g=-XvRiHPzSAp2rgC9Hxdd+pGEHvSTEJ1A1SkWnk1-6xZA@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesse Gross <jesse@nicira.com>
Date: Thu, 29 Aug 2013 14:42:22 -0700

> On Thu, Aug 29, 2013 at 2:21 PM, Geert Uytterhoeven
> <geert@linux-m68k.org> wrote:
>> However, I have some doubts about other alignment "enforcements":
>>
>> "__aligned(__alignof__(long))" makes the whole struct aligned to the
>> alignment rule for "long":
>>    1. This is only 2 bytes on m68k, i.e. != sizeof(long).
>>    2. This is 4 bytes on many 32-bit platforms, which may be less than the
>>       default alignment for "__be64" (cfr. some members of struct
>>       ovs_key_ipv4_tunnel), so this may make those 64-bit members unaligned.
> 
> Do any of those 32-bit architectures actually care about alignment of
> 64 bit values? On 32-bit x86, a long is 32 bits but the alignment
> requirement of __be64 is also 32 bit.

All except x86-32 do, it is in fact the odd man out with respect to this
issue.
