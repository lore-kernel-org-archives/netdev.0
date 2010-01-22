From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: Hang: 2.6.32.4 sky2/DMAR (was [PATCH] sky2: Fix WARNING: at
 lib/dma-debug.c:902 check_sync)
Date: Fri, 22 Jan 2010 17:14:58 -0500
Message-ID: <4B5A2362.6000306@majjas.com>
References: <20100120094103.GA6225@ff.dom.local> <4B58B217.8030001@majjas.com>
 <20100121204133.GB3085@del.dom.local> <4B59E7EB.3050605@majjas.com>
 <20100122215304.GA3105@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	akpm@linux-foundation.org, flyboy@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Michael Chan <mchan@broadcom.com>,
	Don Fry <pcnet32@verizon.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754975Ab0AVWPP@vger.kernel.org>
In-reply-to: <20100122215304.GA3105@del.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/22/2010 4:53 PM, Jarek Poplawski wrote:
> On Fri, Jan 22, 2010 at 01:01:15PM -0500, Michael Breuer wrote:
>    
>> Kernel 2.6.32.4 (git) with the following patches applied:
>>
>> af_packet.c (tpacket_snd version 3)
>> sky2.c pskb_may_pull
>> sky2 fix WARNING at lib/dma-debug.c check_sync
>>      
> I guess, you meant the "sky2.c receive_copy" patch which you tested
> earlier, or at least you managed to crash DMAR with that patch
> before crashing it with Stephen's "lib/dma-debug.c check_sync" patch,
> right?
>
>    
Yes - sorry, correct - all three patches were in the last run. 
Previously, I've encountered the crash without these patches.
>> Running with CONFIG_DMAR=n, system is stable.
>> Running with the exact same source but CONFIG_DMAR=y I get the
>> WARNING (see below) after about 36 hours of uptime (has varied from
>> about 24 to about 48):
>> Smolt profile: http://smolt.fedoraproject.org/show?uuid=pub_bb05c701-1e47-4b3c-9fab-54f520f39d79+
>> I'm also attaching dmesg.old (dmesg from the crash).
>>
>> Subsequent to this the system watchdog reboots the system (it's hung).
>>
>> Of interest: each and every time this has happened the system was
>> under heavy RX load (win7 backup to a cifs share hosted on this
>> server). Also, there is always a dhcp exchange of some sort
>> preceding the event.
>>
>> It is possible that the event is re creatable without DMAR enabled,
>> but I have been unsuccessful in doing so.
>>      
> It would be nice to check now if it's re-creatable without the dhcp
> exchange yet, or at least dhcp through the switch and the router,
> because I suspect there might be something more than a simple drop
> on the switch that affects sky2 stability.
>
> Jarek P.
>    
Not sure I can do that. Note that based on the log messages, there were 
no errors/dropped packets involving dhcp. Moving the dhcp server off of 
the affected machine is not trivial. The dhcp correlation is based on 
logged messages preceding each crash. I cannot confirm that they're 
related, however it's really suspicious. If it helps, HP replaced my 
unmanaged switch with a managed one so I can see whether there were any 
switch events logged the next time I have a crash.

At this point, it seems the following is required to trigger the crash:
1) Uptime of 24-36 hours
2) High RX load on server (cifs traffic is what I've triggered it with).
3) Normal DHCP traffic.

Looks like based on the events I've seen that the high RX load has to be 
sustained for about 15-20 minutes prior to the dhcp traffic. Crash 
follows about a minute later.
