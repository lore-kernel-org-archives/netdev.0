From: Kyle Moffett <mrmacman_g4@mac.com>
Subject: Re: [BUG][debian-2.6.20-1-686] bridging + vlans + "vconfig rem" == stuck kernel
Date: Thu, 10 May 2007 00:34:11 -0400
Message-ID: <EE6715FC-176D-4DA3-A0B3-6BDCC16122A6@mac.com>
References: <2638DE26-D672-4245-BE88-D13B7F0F34A9@mac.com> <46429ED2.10809@candelatech.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, LKML Kernel <linux-kernel@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	OSDL Linux Bridging <bridge@osdl.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout.mac.com ([17.250.248.178]:55335 "EHLO smtpout.mac.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754585AbXEJEeY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2007 00:34:24 -0400
In-Reply-To: <46429ED2.10809@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On May 10, 2007, at 00:25:54, Ben Greear wrote:
> Kyle Moffett wrote:
>> vconfig       D 83CCD8CE     0 16564  16562                      
>> (NOTLB)
>>        efdd7e7c 00000086 ee120afb 83ccd8ce 98f00788 b7083ffa  
>> 5384b49a c76c0b05
>>        9ebaf791 00000004 efdd7e4e 00000007 f1468a90 2ab74174  
>> 00000362 00000326
>>        f1468b9c c180e420 00000001 00000286 c012933c efdd7e8c  
>> df98a000 c180e468
>> Call Trace:
>> [<c012933c>] lock_timer_base+0x15/0x2f
>> [<c0129445>] __mod_timer+0x91/0x9b
>> [<c02988f5>] schedule_timeout+0x70/0x8d
>> [<f8b75209>] vlan_device_event+0x13/0xf8 [8021q]
>
> Looks like a deadlock in the vlan code.  Any chance you can run  
> this test with lockdep enabled?
>
> You could also add a printk in vlan_device_event() to check which  
> event it is hanging on, and the netdevice that is passed in.

Ok, I'll try building a 2.6.21 kernel with lockdep and some debugging  
printk()s in the vlan_device_event() function and get back to you  
tomorrow.  Thanks for the quick response!

> Since the vlan code holds RTNL at this point, then most other  
> network tasks will eventually hang as well.

Well, it's less of an "eventually" and more of an "almost  
immediately".  When that happens pretty close to everything more  
complicated than socket(), bind(), and connect() with straightforward  
UNIX or INET sockets tends to stick completely.

Thanks again!

Cheers,
Kyle Moffett

