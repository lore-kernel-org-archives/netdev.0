From: Ben Greear <greearb@candelatech.com>
Subject: Re: reproducible cxgb kernel panic in FC8 kernel 2.6.23.1-49
Date: Mon, 19 Nov 2007 18:22:23 -0800
Message-ID: <474244DF.6070301@candelatech.com>
References: <473A67CA.8030007@candelatech.com> <473C31AF.9030300@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:33073 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756291AbXKTCWa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Nov 2007 21:22:30 -0500
In-Reply-To: <473C31AF.9030300@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Divy Le Ray wrote:
> Ben Greear wrote:
>> This panic happens (almost?) immediately after starting TCP traffic 
>> between
>> the cxgb nic on this system and another.  We also got at least one crash
>> on a custom/tainted 2.6.20.12 kernel, but it would run for at least
>> a few minutes at ~1Gbps first.
>>
>> I think my serial console chomped some of this..but it's very 
>> reproducible,
>> so if you need more info I can make the terminal wider and do it again.
>>
> Hi Ben,
> 
> I just posted a patch fixing this T2 crash. It appeared in 2.6.22, when 
> eth_type_trans()
> was modified to set skb->dev. cxgb3 got fixed at the time, but I 
> obviously forgot the
> chelsio driver. I'm a bit behind on T2 updates. I will get to it in a 
> few days.

Thanks, that seems to have fixed the crash.

A few other bugs to report:

1)  tx/rx pkt counters remain an zero, even though I know it is passing packets.

2)  There are lots of errors about inadequate headroom in Tx.  I had TCP working
at one point, but then it stopped answering ARP for whatever reason.   Never
got UDP to work at all, even when TCP was working.

3)  After resetting the interface (ifdown, ifup), one machine suddenly had a BUG
(null pointer exception) and rebooted.  The listing in /var/log/messages is not
complete (has no stack-trace or module), so I do not include it here.

This 2.6.23 kernel is patched with some of my own hackings, and it's possible that
my changes are causing the problem (but, it works fine with e1000 NICs).

If you have any patches you would like us to try, we'll be happy to do so.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

