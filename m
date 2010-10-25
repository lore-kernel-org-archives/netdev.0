From: Arnd Hannemann <arnd@arndnet.de>
Subject: Re: [PATCH] net: b43legacy: fix compile error
Date: Mon, 25 Oct 2010 20:26:12 +0200
Message-ID: <4CC5CBC4.7060308@arndnet.de>
References: <1288017690-31248-1-git-send-email-arnd@arndnet.de> <4CC5A301.1080606@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slowhand.arndnet.de ([88.198.19.76]:58557 "EHLO mail.unitix.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751518Ab0JYS0P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Oct 2010 14:26:15 -0400
In-Reply-To: <4CC5A301.1080606@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 25.10.2010 17:32, schrieb Larry Finger:
> On 10/25/2010 09:41 AM, Arnd Hannemann wrote:
>> On todays linus tree the following compile error happened to me:
>>
>>   CC [M]  drivers/net/wireless/b43legacy/xmit.o
>> In file included from include/net/dst.h:11,
>>                  from drivers/net/wireless/b43legacy/xmit.c:31:
>> include/net/dst_ops.h:28: error: expected ':', ',', ';', '}' or '__attribute__' before '____cacheline_aligned_in_smp'
>> include/net/dst_ops.h: In function 'dst_entries_get_fast':
>> include/net/dst_ops.h:33: error: 'struct dst_ops' has no member named 'pcpuc_entries'
>> include/net/dst_ops.h: In function 'dst_entries_get_slow':
>> include/net/dst_ops.h:41: error: 'struct dst_ops' has no member named 'pcpuc_entries'
>> include/net/dst_ops.h: In function 'dst_entries_add':
>> include/net/dst_ops.h:49: error: 'struct dst_ops' has no member named 'pcpuc_entries'
>> include/net/dst_ops.h: In function 'dst_entries_init':
>> include/net/dst_ops.h:55: error: 'struct dst_ops' has no member named 'pcpuc_entries'
>> include/net/dst_ops.h: In function 'dst_entries_destroy':
>> include/net/dst_ops.h:60: error: 'struct dst_ops' has no member named 'pcpuc_entries'
>> make[4]: *** [drivers/net/wireless/b43legacy/xmit.o] Error 1
>> make[3]: *** [drivers/net/wireless/b43legacy] Error 2
>> make[2]: *** [drivers/net/wireless] Error 2
>> make[1]: *** [drivers/net] Error 2
>> make: *** [drivers] Error 2
>>
>> This patch fixes this issue by adding "linux/cache.h" as an include to
>> "include/net/dst_ops.h".
> 
> Strange. Compiling b43legacy from the linux-2.6.git tree (git describe is
> v2.6.36-4464-g229aebb) works fine on x86_64. I wonder what is different.

Exactly the same git describe here.
Maybe your arch includes cache.h already, in my case its a compile for ARM (shmobile).

Regards
Arnd
