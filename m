From: Arnd Hannemann <arnd@arndnet.de>
Subject: Re: [PATCH] net: b43legacy: fix compile error
Date: Mon, 25 Oct 2010 20:44:44 +0200
Message-ID: <4CC5D01C.20804@arndnet.de>
References: <1288017690-31248-1-git-send-email-arnd@arndnet.de> <4CC5A301.1080606@lwfinger.net> <4CC5CBC4.7060308@arndnet.de> <4CC5CE47.2020607@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4CC5CE47.2020607@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 25.10.2010 20:36, schrieb Larry Finger:
> On 10/25/2010 01:26 PM, Arnd Hannemann wrote:
>> Am 25.10.2010 17:32, schrieb Larry Finger:
>>> On 10/25/2010 09:41 AM, Arnd Hannemann wrote:
>>>> On todays linus tree the following compile error happened to me:
>>>>
>>>>   CC [M]  drivers/net/wireless/b43legacy/xmit.o
>>>> In file included from include/net/dst.h:11,
>>>>                  from drivers/net/wireless/b43legacy/xmit.c:31:
>>>> include/net/dst_ops.h:28: error: expected ':', ',', ';', '}' or '__attribute__' before '____cacheline_aligned_in_smp'
>>>> include/net/dst_ops.h: In function 'dst_entries_get_fast':
>>>> include/net/dst_ops.h:33: error: 'struct dst_ops' has no member named 'pcpuc_entries'
>>>> include/net/dst_ops.h: In function 'dst_entries_get_slow':
>>>> include/net/dst_ops.h:41: error: 'struct dst_ops' has no member named 'pcpuc_entries'
>>>> include/net/dst_ops.h: In function 'dst_entries_add':
>>>> include/net/dst_ops.h:49: error: 'struct dst_ops' has no member named 'pcpuc_entries'
>>>> include/net/dst_ops.h: In function 'dst_entries_init':
>>>> include/net/dst_ops.h:55: error: 'struct dst_ops' has no member named 'pcpuc_entries'
>>>> include/net/dst_ops.h: In function 'dst_entries_destroy':
>>>> include/net/dst_ops.h:60: error: 'struct dst_ops' has no member named 'pcpuc_entries'
>>>> make[4]: *** [drivers/net/wireless/b43legacy/xmit.o] Error 1
>>>> make[3]: *** [drivers/net/wireless/b43legacy] Error 2
>>>> make[2]: *** [drivers/net/wireless] Error 2
>>>> make[1]: *** [drivers/net] Error 2
>>>> make: *** [drivers] Error 2
>>>>
>>>> This patch fixes this issue by adding "linux/cache.h" as an include to
>>>> "include/net/dst_ops.h".
>>>
>>> Strange. Compiling b43legacy from the linux-2.6.git tree (git describe is
>>> v2.6.36-4464-g229aebb) works fine on x86_64. I wonder what is different.
>>
>> Exactly the same git describe here.
>> Maybe your arch includes cache.h already, in my case its a compile for ARM (shmobile).
> 
> That probably makes the difference. Using Eric's fix that removes the #include
> <linux/dst.h> should be better. Does it work for you?
> 
> There are probably a lot more of the system includes that may not be needed. If
> I send you a patch removing them, could you test?

As it turns out my card is not supported by b43legacy, but compilation testing,
sure I can test that.

Regards,
Arnd
