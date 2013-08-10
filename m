From: Teco Boot <teco@inf-net.nl>
Subject: Re: [PATCH net] ipv6: don't stop backtracking in fib6_lookup_1 if subtree does not match
Date: Sat, 10 Aug 2013 13:39:12 +0200
Message-ID: <2A0809D4-EBF1-4646-9564-2B7F54956B41@inf-net.nl>
References: <20130807003431.GD16410@order.stressinduktion.org> <EF96A1CB-549E-474A-AF58-10F2D2F2BF4A@inf-net.nl> <20130807200637.GD32257@order.stressinduktion.org> <26D8997F-7CDF-425A-B0DC-4D57996871E5@inf-net.nl> <20130809141939.GL14001@order.stressinduktion.org> <CF3AE072-7B80-4C35-9236-4523EE11629F@inf-net.nl> <20130809145743.GM14001@order.stressinduktion.org>
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:43443 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757465Ab3HJLjS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Aug 2013 07:39:18 -0400
Received: by mail-ee0-f42.google.com with SMTP id b45so2640659eek.1
        for <netdev@vger.kernel.org>; Sat, 10 Aug 2013 04:39:17 -0700 (PDT)
In-Reply-To: <20130809145743.GM14001@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OK, I went back to kernel where I had the ipv6 sadr lookup in cache problem.
There I patched the ip6_fib.c.
Patch works !!

The hang problem in 3.8.0-28 has lower priority for me. Maybe I'll check current -net-next later. Don't hold your breath.

Now this patch should go mainline and older kernels, I think.
What is the next step?

Teco


Op 9 aug. 2013, om 16:57 heeft Hannes Frederic Sowa <hannes@stressinduktion.org> het volgende geschreven:

> On Fri, Aug 09, 2013 at 04:40:03PM +0200, Teco Boot wrote:
>> 
>> Op 9 aug. 2013, om 16:19 heeft Hannes Frederic Sowa <hannes@stressinduktion.org> het volgende geschreven:
>> 
>>> On Fri, Aug 09, 2013 at 04:12:20PM +0200, Teco Boot wrote:
>>>> Double checked, it works. Tested with Common Open Research Emulator (CORE, from NRL).
>>>> 
>>>> === But ===
>>>> 
>>>> I had some problems with CORE. Could be me, new kernel version, the patch, CORE using network namespaces, or combination of that. sudo hangs, reboot hangs, ip address show hangs.
>>>> With ps -ef, I see some suspected items:
>>>> root      4858  4161  0 15:57 ?        00:00:00 /sbin/ip -6 addr flush dev eth0
>>>> root      4859     2  0 15:57 ?        00:00:00 [kworker/0:3]
>>>> In the emulation I use, there was no IPv6.
>>>> 
>>>> I'll try to figure out if it is CORE & netns in combination with patch. Or just the patch. Or just the new kernel.
>>>> Just to speed up, any idea where to look for?
>>> 
>>> echo t > /proc/sysrq-trigger and check dmesg while the system hangs. Maybe you
>>> have to use a serial console and send the sysrq over keyboard/break.
>> 
>> System was still running.
>> Cleared dmesg, silence.
>> Then performed echo t > /proc/sysrq-trigger.
>> Quite large dump.
>> Afterwards, silence again.
> 
> I think you are experience high fib6_gc_lock contention (and while the lock is
> held you also hold rtnl_lock, which let's all the other processes hang).
> Please test if these patches make things more smooth for you:
> 
> https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=2ac3ac8f86f2fe065d746d9a9abaca867adec577
> https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=49a18d86f66d33a20144ecb5a34bba0d1856b260
> 
> Thanks,
> 
>  Hannes
> 
