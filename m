From: Reuben Farrelly <reuben-lkml@reub.net>
Subject: Re: ip_conntrack related slab error (Re: Fw: Re: 2.6.16-rc1-mm3)
Date: Tue, 31 Jan 2006 23:05:43 +1300
Message-ID: <43DF3677.8040701@reub.net>
References: <20060130221429.5f12d947.akpm@osdl.org> <20060131092447.GL4603@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>,
	Linux Kernel Mailinglist <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750721AbWAaKFu@vger.kernel.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20060131092447.GL4603@sunbeam.de.gnumonks.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 31/01/2006 10:24 p.m., Harald Welte wrote:
>> Begin forwarded message:
>>
>> Date: Sat, 28 Jan 2006 00:47:06 +1300
>> From: Reuben Farrelly <reuben-lkml@reub.net>
>> To: Andrew Morton <akpm@osdl.org>
>> Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
>> Subject: Re: 2.6.16-rc1-mm3
>>
>> Just triggered this one, which had a fairly bad effect on connectivity to the box:
>>
>> i2c /dev entries driver
>> slab error in kmem_cache_destroy(): cache `ip_conntrack': Can't free all objects
>>   [<b010412b>] show_trace+0xd/0xf
>>   [<b01041cc>] dump_stack+0x17/0x19
>>   [<b0155d04>] kmem_cache_destroy+0x9b/0x1a9
>>   [<f0ebf701>] ip_conntrack_cleanup+0x5d/0x10e [ip_conntrack]
>>   [<f0ebe31e>] init_or_cleanup+0x1f8/0x283 [ip_conntrack]
>>   [<f0ec2c4e>] fini+0xa/0x66 [ip_conntrack]
>>   [<b0136d06>] sys_delete_module+0x161/0x1fb
>>   [<b0102b3f>] sysenter_past_esp+0x54/0x75
>> Removing netfilter NETLINK layer.
>> [root@tornado log]#
>>
>> I was just reading IMAP mail at the time, ie same as I'd been doing for an hour 
>> or two beforehand and not altering config of the box in any way.  I was able to 
>> log on via console but lost all network connectivity and had to reboot :(
> 
> The codepath you see in that backtrace is only hit during load or
> removal of the 'ip_conntrack' module.  While this certainly still should
> not oops, your description of 'not doing anything but IMAP reading' is
> certainly not true.  

With the greatest of respect (which I do have for you Harald), I don't think 
being essentially called a liar is very fair.

I've no reason to not report exactly what I observed and noted and what I did or 
didn't do before noting it, and while you may argue that it doesn't match with 
what you expect, that doesn't mean that I'm making stuff up.  More likely it 
means that neither you or I understand quite what was happening at the time.

> Could you please describe what actually happened when that bug happened?
> It looks to me that you were unloading ip_conntrack_netlink.ko followed
> by ip_conntrack.ko.

It's now four days later.  I wrote the email a few minutes after noting the 
oops, so if I was fiddling with iptables at the time I'm sure I would have said 
so.  I mean, why wouldn't I?

I'll try to reproduce it, but as I've no idea what triggered it in the first 
place it may be a bit tricky.

Noting that a reboot of the box does not even load the ip_conntrack_netlink 
module, which if I was indeed messing with it, I would have probably had to 
force the module to load.  I think I'd know if I was doing that.........

>> Generic details such as .config is at http://www.reub.net/files/kernel/
> 
> You don't have permission to access /files/kernel/ on this server.

Apologies.  My bad, it's fixed now.

Anyway, let's get to the bottom of the problem rather than get personal about 
what actually happened.

Reuben
