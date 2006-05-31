From: Ben Greear <greearb@candelatech.com>
Subject: Re: TCP connection hang problem with 2.6.16.16, e1000 (found work-around)
Date: Wed, 31 May 2006 15:38:33 -0700
Message-ID: <447E1AE9.8090102@candelatech.com>
References: <447DC830.4080201@candelatech.com>	<447DD870.80107@intel.com>	<447DD9B5.9050100@candelatech.com>	<447DF085.2050604@candelatech.com>	<447E0E69.3080006@candelatech.com> <20060531151018.17110684@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:59098 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S965217AbWEaWik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 May 2006 18:38:40 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060531151018.17110684@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Wed, 31 May 2006 14:45:13 -0700
> Ben Greear <greearb@candelatech.com> wrote:
> 
> 
>>Ok, I think I found the problem.  It appears to be at least partially
>>self-inflicted.  I was modifying the kernel buffer settings via /proc/*
>>to improve performance.  I noticed that when I used kernel-defaults,
>>the TCP connection hangs stopped (and ran ~20% slower).  My personal opinion
>>is that this is still a bug somewhere in TCP, but at least I have a work-around.
> 
> 
> If you set bogus values, you can end up consuming all the memory on your system.

I still had some sort of memory..ie I could run other applications and could
start a second TCP connection on the same interface.  It is true that you can
truly OOM systems with bad settings here, but my machine has 2GB of RAM, and
I think my setting were low enough that it should not have run out.  It also
had enough memory left to spam the duplicate TCP acks at around 200kpps in
both directions!  Manually over-riding the write buffer size had little or
no effect:  It would still hang.

>>The new settings that appear to work around the TCP connection hang,
>>and still give decent performance are below.  Documentation being thin,
>>I used the suggested values in Documentation/networking/ixgb.txt as
>>hints:
> 
> 
> Settings don't belong in this Documentation file because it a general
> thing not specific to that hardware.

The file was describing how to tune for good performance using their
NICs.

At least most of the TCP settings are described in the networking/ip-sysctl.txt
file, but I could find nothing on the core.rmem_max setting, except in examples
in the 10Gbe NIC help texts.

It would be nice to either have the core.* values described in the
ip-sysctl.txt file, or perhaps add a new file.

There are tuning tips all over the web too...often quite badly
outdated it seems.  Might be a good thing to add to the linux-net wiki.

I'd give it a try, but obviously my info is suspect! :P

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

