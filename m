From: Dick Hollenbeck <dick@softplc.com>
Subject: Re: KS8695: possible NAPI issue
Date: Tue, 02 Mar 2010 08:09:06 -0600
Message-ID: <4B8D1C02.1010204@softplc.com>
References: <f69abfc31003020404y7af77fe5icefeee4644c7d08e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, figo1802@gmail.com, zealcook@gmail.com
To: Yegor Yefremov <yegorslists@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kcmailp01.birch.net ([216.212.0.96]:59378 "EHLO mx01.birch.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752357Ab0CBOP0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Mar 2010 09:15:26 -0500
In-Reply-To: <f69abfc31003020404y7af77fe5icefeee4644c7d08e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yegor Yefremov wrote:
> I'm using 2.6.33 kernel and I noticed such a strange behavior:
>
> after system start I transfer one file via netcat from my development
> host, after this transfer the network is not functioning i.e. no pings
> possible etc.
>
> To narrow down the problem I checked out this commit
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=451f14439847db302e5104c44458b2dbb4b1829d.
> Till here the network driver is functioning as intended, but after
> NAPI introduction I have this issue. With latest git-pull of "Linus'
> kernel tree" I can't even ping right after the systems start.
>
> Any Ideas? What am I missing?
>   

No idea, although I am using the same ARM chip, my kernel is at 
2.6.30.5, and except for this occasional loss of connection I get, the 
ethernet driver seems to work better than what you are reporting.

I would get your printk() working to the internal ring buffer, and then 
simply instrument the key pieces of code with printk()s until the 
situation becomes clear.  You can also watch

# cat /proc/interrupts to see which interrupt handlers are firing, 
before and after an activity.  Reception of a frame all starts with an 
interrupt handler usually.

printk() should be able to print even from within an interrupt handler, 
so long as you are only going to that internal ring buffer.


Dick

> Regards,
> Yegor
>
>   

