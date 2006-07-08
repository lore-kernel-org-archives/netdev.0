From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC NET 00/04]: Increase number of possible routing tables
Date: Fri, 07 Jul 2006 18:07:11 -0700
Message-ID: <44AF053F.70605@candelatech.com>
References: <20060703075259.6286.67397.sendpatchset@localhost.localdomain> <44AE15C3.8050900@trash.net> <44AEA462.1080505@candelatech.com> <44AEBCE7.2030203@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>, Robert.Olsson@data.slu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:3507 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S1750903AbWGHBHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2006 21:07:22 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <44AEBCE7.2030203@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Ben Greear wrote:
> 
>>Patrick McHardy wrote:
>>
>>
>>>>I took on Ben's challenge to increase the number of possible routing
>>>>tables, these are the resulting patches.
>>
>>
>>I am seeing problems..though they could be with the way I'm using the tool
>>or pehaps I patched the kernel incorrectly.
>>
>>I applied the 3 patches to 2.6.17..all patches applied without problem,
>>but with a few lines of fuzz.  I get the same behaviour with and
>>without the new 'ip' patches applied.
>>
>>If I do an 'ip ru show', then I see lots of tables, though not all it
>>seems. (I have not tried beyond 205 yet).  But, if I do an
>>'ip route show table XX', then I see nothing or incorrect values.
> 
> 
> My patches introduced a bug when dumping tables which could lead to
> incorrect routes beeing dumped. A second bug (that already existed)
> makes the kernel fail when dumping more rules than fit in a skb.
> I think I've already seen the patch to address the second problem
> a short time ago sent by someone else. Anyway, this patch should
> fix both.

With this patch applied everything is looking much better.  I currently
have 400+ interfaces and one routing table per interface, and traffic
is passing as expected.

This is probably due to my own application polling interfaces for
stat updates...but I am seeing over 50% usage (with more system than user-space)
in this setup on an otherwise lightly loaded system.  top shows no process averaging
more than about 2% CPU (and only 2-3 are above 0.0 typically), which I find
a little strange.  load is around 3.0.

I'll dig into my code and see if I can tune the stat-gathering logic a bit...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

