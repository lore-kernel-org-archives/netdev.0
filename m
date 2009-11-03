From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: HTB accuracy on 10GbE
Date: Tue, 03 Nov 2009 10:43:30 +0300
Message-ID: <4AEFDF22.8000405@bigtelecom.ru>
References: <b30d1c3b0911012322v5d553fd6va56575fcf5e3daf8@mail.gmail.com>	<4AEEFE2E.7090706@trash.net> <20091102125345.3c39c42e@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Ryousei Takano <ryousei@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	takano-ryousei@aist.go.jp, Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:54728 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755486AbZKCHnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 02:43:35 -0500
In-Reply-To: <20091102125345.3c39c42e@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello dear netdev team!

Linux all time go with the times :)
Network in world go to use 10G technologies. I can test any stress patches in produce system for linux developers :)
I discharge from out company in 1 December and have 1 month for all tests.
I believe that linux net dev team do it easy. Need only begin :) Lets do it together :)

Jarek, you many times help to us fix small problems in HTB, thanks for this! All work great! Now netdev team have "crazy" Eric that do great code and not afraid do big code changes. Maybe together you think about changes and create mega patch for my testing? :)
I alltime read all changes in code from netdev mail list. Its my coffee time in morning :) 

Also interesting that say David. That linux networking planes to full support 10g technologies?

We buy 4x4 Xeon Quad + IntelCX4 x 2 network cards for test support 10g shaper in our network :) Lets begin test! :)

Best regals, Slavon.
Tech Director Assistant.
JSC BIG Telecom
Moscow, Russia

> On Mon, 02 Nov 2009 16:43:42 +0100
> Patrick McHardy <kaber@trash.net> wrote:
> 
>> Ryousei Takano wrote:
>>> Hi Stephen and all,
>>>
>>> I have observed a HTB accuracy problem on the Linux kernel 2.6.30 and
>>> the Myri-10G 10 GbE NIC.
>>> HTB can control the transmission rate at Gigabit speed, however it can
>>> not work well at 10 Gigabit speed.
>>>
>>> I asked Stephen this problem at Japan Linux Symposium.  He mentioned a
>>> HTB bug related to the timer granularity.
>>> I want to know what is happen, and what should be do for fixing it.
>>>
>>> Any comments and suggestions will be welcome.
>>>
>>> For more detail, please see the following page:
>>> http://code.google.com/p/pspacer/wiki/HTBon10GbE
>> This is not an easy problem to fix. Userspace, the kernel and the
>> netlink API use 32 bit for timing related values, which is too small
>> to use more than microsecond resolution. All of them need to be
>> converted to use bigger types, additionally some kind of compatibility
>> handling to deal with old iproute versions still using microsecond
>> resolution is required.
> 
> The existing API is a legacy mish-mash. The field is limited to 32 bits,
> but it might be possible to use a finer scale.
> 
> Maybe if kernel advertised finer resolution through /proc/net/psched
> then table could be finer grained. This would maintain compatibility
> between kernel and user space. You would need to have new kernel and
> new iproute to get nanosecond resolution but older combinations would
> still work.
> 
> The downside is that by using nanosecond resolution the rates are upper
> bounded at 4.2seconds / packet.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 

