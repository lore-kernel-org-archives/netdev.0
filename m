From: Antonio Almeida <vexwek@gmail.com>
Subject: Re: HTB - What's the minimal value for 'rate' parameter?
Date: Fri, 9 Apr 2010 16:40:44 +0100
Message-ID: <i2k298f5c051004090840y7e47a53eqd17b0685088551ac@mail.gmail.com>
References: <z2q298f5c051004080407r5dfb27fai74c5cf74d0048ca5@mail.gmail.com>
	 <4BBE4BB4.1060209@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net,
	devik@cdi.cz
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:63967 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754184Ab0DIPkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 11:40:46 -0400
Received: by fg-out-1718.google.com with SMTP id d23so1252299fga.1
        for <netdev@vger.kernel.org>; Fri, 09 Apr 2010 08:40:45 -0700 (PDT)
In-Reply-To: <4BBE4BB4.1060209@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So, what about the rate limit miss?
As you can see the ceil of class 1:2 is set to 4096Kbit but its
sending rate is actually 8071Kbit!
It looks like classes 1:10 and 1:11 are ignoring hierarchical rate
restrictions of class 1:2
Here:
class htb 1:2 parent 1:1 rate 4096Kbit ceil 4096Kbit burst 3655b cburst 3655b
 Sent 84285894 bytes 55671 pkt (dropped 0, overlimits 0 requeues 0)
 rate 8071Kbit 666pps backlog 0b 0p requeues 0
 lended: 0 borrowed: 0 giants: 0
 tokens: -937499999 ctokens: -937499999




On Thu, Apr 8, 2010 at 10:33 PM, Jarek Poplawski <jarkao2@gmail.com> wrote:
> Antonio Almeida wrote, On 04/08/2010 01:07 PM:
>
>> Hi!
>
> Hi!
>
>> I've been using HTB for a while, and we've already sent some e-mails
>> each other when resolving HTB accuracy issue.
>> When using HTB, I realised that for some configurations the rate limit
>> doesn't work.
>> I suspect that the problem is the minimum value of rate parameter,
>> which I cant figure out what is.
>>
>> I simple configuration that turns out to be wrong is as fallows: The
>> root (1:1) gets the link bandwidth configuration; the second (1:2) is
>> set to 4096Kbit; then I have two branches (1:10 and 1:11) with rate
>> 1024Kbit and ceil 4096Kbit; and finally a leaf class in each branch
>> (1:111 below 1:11, and 1:101 below 1:10) with rate 8bit and ceil
>> 4096Kbit, and the same priority.
>> I don't want to have sustained rate, and since I must configure 'rate'
>> parameter I decide to set it to 8bits - which is the minimal accepted
>> value. My cue goes for 'rate' parameter. If I set 'rate' parameter to
>> 1Kbit for instance, the problem disappears and the shaping is done
>> perfectly.
>>
>> So, I'm looking for help to find out if the problem is actually in
>> this parameter configuration or if it's just coincidence and I'll get
>> the same problem ahead :(
>> What's the minimal value for 'rate' parameter using HTB qdisc?
>
>
> I think "reasonable" or "minimally useful" (for common use) should be
> enough, and 8bits meaning one 1500 byte packet per 25 minutes or
> something, doesn't look like this to me.
>
> This changelog:
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=a4a710c4a7490587406462bf1d54504b7783d7d7
> mentions ~2 minutes as max time for accounting, so 1 max packet
> per 2 minutes should give such a minimal rate, I guess, but I'd
> still multiply it a few times to call it useful.
>
> Regards,
> Jarek P.
>
>
>
