From: Michal Simek <monstr@monstr.eu>
Subject: Re: net: more accurate skb truesize - regression on Microblaze
Date: Tue, 10 Apr 2012 10:36:57 +0200
Message-ID: <4F83F129.5040502@monstr.eu>
References: <4F83EB0E.4020104@monstr.eu> <1334046444.3126.12.camel@edumazet-glaptop>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	John Williams <john.williams@petalogix.com>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:33905 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752827Ab2DJIhC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 04:37:02 -0400
Received: by eekc41 with SMTP id c41so1244378eek.19
        for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 01:37:01 -0700 (PDT)
In-Reply-To: <1334046444.3126.12.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/10/2012 10:27 AM, Eric Dumazet wrote:
> On Tue, 2012-04-10 at 10:10 +0200, Michal Simek wrote:
>> Hi Eric,
>>
>> I have spent some time to investigate what it is causing regression on our network bechmark
>> and I have identified that your patch "net: more accurate skb truesize" is causing that.
>>
>> I see regression especially on incoming tcp (RX) connection which is 20%. On TX I see regression till 5%.
>>
>> In general microblaze systems are pretty sensitive for memory usage and working with it.
>> Increasing packet sizes has big impact on performance.
>> I was surprised that regression is so high.
>>
>>   From microblaze point of view is more important to remove that performance regression
>> than having more accurate memory accounting. 20% performance regression is simple so high
>> for that.
>> Isn't there any other way to doing better memory accounting?
>> Or is there any workaround which would be possible to use?
>>
>> Thanks,
>> Michal
>>
>
> Hi Michal
>
> We are currently working on the issue.
>
> TCP stack was a bit optimistic in the ideal skb->len / skb->truesize
> ratio that happened to 'mostly work' before my patch, but not anymore
> after it.
>
> memory accounting was wrong, we really wanted to be accurate, or risk
> OOM and crashes.
>
> Now we must fix tcp.
>
> In the meantime you could try :
>
> echo 1>/proc/sys/net/ipv4/tcp_adv_win_scale

will retest it and let you know.

Thanks,
Michal



-- 
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/fdt/
Microblaze U-BOOT custodian
