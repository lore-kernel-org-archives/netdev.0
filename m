From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net 1/2] net: ipmr: fix static mfc/dev leaks on table destruction
Date: Fri, 20 Nov 2015 10:52:00 -0800
Message-ID: <CAHA+R7PL4X-FRuEU8pW_kr2AroQ-hFYbPOR83C_ew2ivF+o0Og@mail.gmail.com>
References: <1448024060-20466-1-git-send-email-razor@blackwall.org>
	<1448024060-20466-2-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	David Miller <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f176.google.com ([209.85.160.176]:33198 "EHLO
	mail-yk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759545AbbKTSwB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 13:52:01 -0500
Received: by ykdv3 with SMTP id v3so175107574ykd.0
        for <netdev@vger.kernel.org>; Fri, 20 Nov 2015 10:52:00 -0800 (PST)
In-Reply-To: <1448024060-20466-2-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 20, 2015 at 4:54 AM, Nikolay Aleksandrov
<razor@blackwall.org> wrote:
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>
> When destroying an mrt table the static mfc entries and the static
> devices are kept, which leads to devices that can never be destroyed
> (because of refcnt taken) and leaked memory, for example:
> unreferenced object 0xffff880034c144c0 (size 192):
>   comm "mfc-broken", pid 4777, jiffies 4320349055 (age 46001.964s)
>   hex dump (first 32 bytes):
>     98 53 f0 34 00 88 ff ff 98 53 f0 34 00 88 ff ff  .S.4.....S.4....
>     ef 0a 0a 14 01 02 03 04 00 00 00 00 01 00 00 00  ................
>   backtrace:
>     [<ffffffff815c1b9e>] kmemleak_alloc+0x4e/0xb0
>     [<ffffffff811ea6e0>] kmem_cache_alloc+0x190/0x300
>     [<ffffffff815931cb>] ip_mroute_setsockopt+0x5cb/0x910
>     [<ffffffff8153d575>] do_ip_setsockopt.isra.11+0x105/0xff0
>     [<ffffffff8153e490>] ip_setsockopt+0x30/0xa0
>     [<ffffffff81564e13>] raw_setsockopt+0x33/0x90
>     [<ffffffff814d1e14>] sock_common_setsockopt+0x14/0x20
>     [<ffffffff814d0b51>] SyS_setsockopt+0x71/0xc0
>     [<ffffffff815cdbf6>] entry_SYSCALL_64_fastpath+0x16/0x7a
>     [<ffffffffffffffff>] 0xffffffffffffffff
>
> Make sure that everything is cleaned on netns destruction.
>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Looks good to me,

Reviewed-by: Cong Wang <cwang@twopensource.com>
