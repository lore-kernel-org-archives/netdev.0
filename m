From: Jan Synacek <jsynacek@redhat.com>
Subject: Re: iputils: ping -I <iface>
Date: Fri, 30 Nov 2012 07:06:03 +0100
Message-ID: <50B84CCB.7000502@redhat.com>
References: <50B76D5B.8010804@redhat.com> <50B7BC0F.6000709@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12371 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755180Ab2K3GGJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2012 01:06:09 -0500
In-Reply-To: <50B7BC0F.6000709@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/29/2012 08:48 PM, Ben Greear wrote:
> On 11/29/2012 06:12 AM, Jan Synacek wrote:
>> Hello,
>>
>> There seems to be a bug(?) when calling ping with -I lo:
>>
>> $ ping -I lo kernel.org
>>
>> PING kernel.org (149.20.4.69) from 192.168.1.10 lo: 56(84) bytes of data.
>> ^C
>>
>> Note that 192.168.1.10 is my primary interface's address (em1). However, no
>> replies are coming back.
>>
>> $ ping -I em1 kernel.org
>>
>> PING kernel.org (149.20.4.69) from 192.168.1.10 em1: 56(84) bytes of data.
>> 64 bytes from pub2.kernel.org (149.20.4.69): icmp_seq=1 ttl=42 time=202 ms
>> 64 bytes from pub2.kernel.org (149.20.4.69): icmp_seq=2 ttl=42 time=187 ms
>> ^C
>>
>> Works as expected.
>>
>> I know that binding to loopback probably doesn't make much sense, but I think
>> that ping should be able to cope with that.
> 
> I think it would be wrong if ping worked as you suggest.  Binding to an
> interface means use that interface as the source of your packets, and having
> it bind hard helps when using systems with multiple NICs on same subnet
> (or possibly, same IP).

I just wanted to point out that if I call ping with -I lo, its 'from' address is
wrong (in my case 192.168.1.10) and nothing happens (that's, I guess, expected
if it really bound to loopback). If I call ping with the -I <the same address>
or -I em1 (the same address again), it works as expected. I'm sorry if I wasn't
clear enough.

> 
>> Also, it would be nice to mention the difference between -I <ip> and -I <iface>
>> in the manpage.
> 
> In my opinion, -I <iface> should use SO_BINDTODEVICE, but at least in
> older versions of ping it did not.

Ping does use SO_BINDTODEVICE.

> 
> Thanks,
> Ben
> 

Regards,
-- 
Jan Synacek
Software Engineer, BaseOS team Brno, Red Hat
