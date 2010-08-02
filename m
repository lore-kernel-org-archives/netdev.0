From: Mitchell Erblich <erblichs@earthlink.net>
Subject: Re: why do we need printk on sending syn flood cookie?
Date: Mon, 2 Aug 2010 15:30:17 -0700
Message-ID: <BF6AF151-741E-4242-938B-E1C8D93579C3@earthlink.net>
References: <480391280735894@web102.yandex.ru> <20100802081716.GA8374@Chamillionaire.breakpoint.cc> <23001280765498@web50.yandex.ru> <667FAE9E-C5B5-4C26-B3AD-3C459CECA4AB@earthlink.net> <148911280783676@web125.yandex.ru>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Franchoze Eric <franchoze@yandex.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-junco.atl.sa.earthlink.net ([209.86.89.63]:58916 "EHLO
	elasmtp-junco.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750959Ab0HBWa1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Aug 2010 18:30:27 -0400
In-Reply-To: <148911280783676@web125.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Aug 2, 2010, at 2:14 PM, Franchoze Eric wrote:

> 
> 
> 02.08.10, 22:10, "Mitchell Erblich" <erblichs@earthlink.net>:
> 
>> 
>> On Aug 2, 2010, at 9:11 AM, Franchoze Eric wrote:
>> 
>>> 
>>> 
>>> 02.08.10, 12:17, "Florian Westphal" :
>>> 
>>>> Franchoze Eric  wrote:
>>>>> Just sirious why do we need printk each 1 second (60*HZ) about possible syn-flood? It really floods dmesg. Is there something dengerous? I have suggestion to turn off printk about sending tcp cookie each 1 second.
>>>> 
>>>> It is handled exactly like other printks in the networking path,
>>>> e.g. receipt of tcp wscale == 15.
>>>> 
>>>> Why does this need special treatment?
>>>> 
>>> 
>>> For now I see "possible SYN flooding on port %d. Sending cookies.\n" message each second on my server. I know that there are a lot of SYNs and I know that kernel sends cookie. Why do I need so mach printk?
>>> So I suggested add new value to /proc/sys/net/ipv4/tcp_syncookies, which will enable cookie but this printk will be turned off.
>> 
>> 
>> Once print per sec is a very good GENERIC informative msg to an admin that 
>> this system either has some  very small config'd or default values
>> (normally set up as a percentage of memory or set sock option and/or .. )
>> and/or that for some reason that a large number of SYNs are being rec'vd
>> and/or that a number of connections are being un/intentionally being
>> retried and/or dropped
>> 
> 
> There is no much settings to tune syn requests.
> tcp_max_syn_backlog, tcp_synack_retries, tcp_abort_on_overflow

The key is that you need a reproduceable test case and determine what type of
changes you want to make.

also review the listen (backlog) code and : tcp.h: TCP_SYNQ_HSIZE

	Other than that, their are MANY changes that can be done to scale this section
	of code.

	What is the latency of serving an ACK? What is a RTT of a SYN/ACK?
	Why is each client trying to ESTABLISH a connection at the same time?
	etc.

	Is your server capable of serving 3000 clients? Are they sending 1 MTU per sec,
	or are they doing 1000s of pings per sec, or are they doing bulk-data-transfer or?
	Thus, even if you are able to keep 3000 connections open at one time, can
	 your server properly respond to their requests in a timely manner?

	Mitchell Erblich
 
> 
> As for me, than I have about 3000 clients which do a little bit less then 3000 SYNs for nginx port.
> I'm ok with sending syn cookies to clients. Also it's not possible to turn syncs off with setting
> bigger value to tcp_max_syn_backlog and application works well so I would simple remove 
> this messages from dmesg.
> 
> If I limit syncs with iptables it starts to drop needed packets. So it's no solution. That's why I think that we need turn off 
> printk without turning off syn cookies.  
> 
>> Remember each printk may only be a small fraction of the number of SYNs
>> rcv'd and this fraction COULD depend on the Mb/Gb of the intf(s) or more
>> likely some type of  avg of summation of the number of network paths
>> involved.
>> 
>> Mitchell Erblich
>> 
>> 
>> 
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
>> 
>> 

