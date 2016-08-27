From: Oleg Drokin <green@linuxhacker.ru>
Subject: Re: [PATCH] bridge: Fix format string for %ul
Date: Sat, 27 Aug 2016 12:36:49 -0400
Message-ID: <D79B6506-31BF-4B39-A81C-F3900F062164@linuxhacker.ru>
References: <1472267428-810527-1-git-send-email-green@linuxhacker.ru> <11e50e3c-2e1f-4614-07e3-3bd144af4f94@cogentembedded.com> <95BF7F27-59F7-4BDA-941B-BB00C60423A4@linuxhacker.ru> <59758948-d899-a32f-12af-a56b8c0da6c1@cogentembedded.com>
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8BIT
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>,
        bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <59758948-d899-a32f-12af-a56b8c0da6c1@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Aug 27, 2016, at 12:18 PM, Sergei Shtylyov wrote:

> Hello.
> 
> On 8/27/2016 6:58 PM, Oleg Drokin wrote:
> 
>>>> %ul would print an unsigned value and a letter l,
>>>> likely it was %lu that was meant to print the long int,
>>>> but in reality the values printed there are just regular signed
>>> 
>>>  Signed? Then you need probably "%d" or "%i"…
>> 
>> They are signed in the struct definition, but in reality they
>> designate time, so could not be negative, I imagine?
> 
>   That doesn't matter. If the type is signed, it should be printed as signed.
> Doesn't gcc complain about the format specifiers not matching the values passed?

only if the size differs.

I don't care either way.
I can change the struct to unsigned too, but if we want super correctness,
the problem lies deeper.

E.g. if we look how those times are derived, the age comes as:
static inline int br_get_ticks(const unsigned char *src)
{
        unsigned long ticks = get_unaligned_be16(src);

        return DIV_ROUND_UP(ticks * HZ, STP_HZ);
}

So we divide unsigned value by positive value and get a signed result ;)

there's a struct net_bridge_port with similar members in this are that are
unsigned long, so I guess we should convert to unsigned long in the
struct br_config_bpdu, do you want a patch for that separately or as part of this one?

> 
>>>> ints, so just dropping the l altogether.
>>>> 
>>>> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
>>> [...]
> 
> MBR, Sergei
