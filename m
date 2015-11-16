From: Grant Zhang <gzhang@fastly.com>
Subject: Re: Kernel 4.1 hang, apparently in __inet_lookup_established
Date: Sun, 15 Nov 2015 16:58:33 -0800
Message-ID: <56492A39.2060307@fastly.com>
References: <5726932.6r4XOZ2Km2@rofl>
 <1443025879.29850.116.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NETDEV <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick Schaaf <kernelorg@bof.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33485 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752505AbbKPA6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Nov 2015 19:58:36 -0500
Received: by pabfh17 with SMTP id fh17so158306138pab.0
        for <netdev@vger.kernel.org>; Sun, 15 Nov 2015 16:58:35 -0800 (PST)
In-Reply-To: <1443025879.29850.116.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Patrick,

Have you tried the two patches Eric mentioned? One of my 4.1.11 server 
just hanged with very similar stack trace and I am wondering whether the 
aforementioned patches would help.

Thanks,

Grant

On 23/09/2015 09:31, Eric Dumazet wrote:
> On Wed, 2015-09-23 at 10:25 +0200, Patrick Schaaf wrote:
>> Dear kernel developers,
>>
>> I recently started to upgrade my production hosts and VMs from the 3.14 series
>> to 4.1 kernels, starting with 4.1.6. Yesterday, for the second time after I
>> started these upgrades, I experienced one of our webserver VMs hanging.
>>
>> The first time this happened, the VM hung completely, all 5 virtual cores
>> spinning at 100%, ping still worked, but nothing else, including no virsh
>> console reaction - I had to destroy and restart that VM. No messages were to
>> be found.
>>
>> Yesterday, when it happened the second time, I found the VM spinning on a
>> single core only, and could still connect to it via ssh - but it stopped
>> accepting apache connections. The core it spun on showed 100% time used in
>> "si", with top, and it produced the messages appended below. The VM did not
>> shutdown properly when told to, and had to be destroyed again.
>>
>> If I read that dmesg output correctly it spins in __inet_lookup_established,
>> which indeed reads like it has infinite spin potential. But that code itself
>> did not change relative to the 3.14 series we've been running for a long time
>> without the issues - so the root cause would be something else.
>>
>> For our production systems I'll revert to the 3.14 series, but maybe this
>> report may help somebody understand what's going on.
>>
>> best regards
>>    Patrick
>
>
> You could try following commits :
>
> http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=ed2e923945892a8372ab70d2f61d364b0b6d9054
>
> http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=29c6852602e259d2c1882f320b29d5c3fec0de04
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
