From: Ben Greear <greearb@candelatech.com>
Subject: Re: skb_warn_bad_offload related to IPv6 in 3.9.9+
Date: Thu, 11 Jul 2013 15:08:14 -0700
Message-ID: <51DF2CCE.9050103@candelatech.com>
References: <51DEFEEB.1080408@candelatech.com> <1373578657.2085.20.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:33285 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754416Ab3GKWIR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 18:08:17 -0400
In-Reply-To: <1373578657.2085.20.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/11/2013 02:37 PM, Ben Hutchings wrote:
> On Thu, 2013-07-11 at 11:52 -0700, Ben Greear wrote:
>> This kernel has local patches applied...but I don't think it has anything
>> that would cause this....
>>
>> The wanlink module is something we added.  It is now GPL, but code is
>> not upstream.  I don't think it's in directly related to the splat though...
>>
>> Only saw one splat, and system remains stable as far as we can tell.
>>
>> ------------[ cut here ]------------
>> WARNING: at /home/greearb/git/linux-3.9.dev.y/net/core/dev.c:2179 skb_warn_bad_offload+0xc2/0xcb()
>> Hardware name: X7DBU
>> e1000e: caps=(0x00000000700003a9, 0x0000000000000000) len=2942 data_len=1428 gso_size=1428 gso_type=16 ip_summed=1
> [...]
>
> The skb requires TSO, which requires that ip_summed = CHECKSUM_PARTIAL.
> But ip_summed = CHECKSUM_UNNECESSARY.
>
> To me, this suggests that the receiving device i.e. wanlink has some
> kind of broken LRO that can't be turned off...

The wanlink module is a set of 2-port bridges with network emulation
feature set.

I am not certain the IPv6 traffic in this splat traversed it at all, but
I guess it is possible.  We automatically disable LRO on ports used
by the wanlink bridge, by the way.

I think the wanlink stuff only shows up in the trace because
it was interrupted by IRQ and then the soft-irq packet rx
path caused the splat.  I could easily be mistaken, however.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
