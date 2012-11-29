From: Ben Greear <greearb@candelatech.com>
Subject: Re: iputils: ping -I <iface>
Date: Thu, 29 Nov 2012 11:48:31 -0800
Message-ID: <50B7BC0F.6000709@candelatech.com>
References: <50B76D5B.8010804@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
To: Jan Synacek <jsynacek@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:37650 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753046Ab2K2Tsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 14:48:46 -0500
In-Reply-To: <50B76D5B.8010804@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/29/2012 06:12 AM, Jan Synacek wrote:
> Hello,
>
> There seems to be a bug(?) when calling ping with -I lo:
>
> $ ping -I lo kernel.org
>
> PING kernel.org (149.20.4.69) from 192.168.1.10 lo: 56(84) bytes of data.
> ^C
>
> Note that 192.168.1.10 is my primary interface's address (em1). However, no
> replies are coming back.
>
> $ ping -I em1 kernel.org
>
> PING kernel.org (149.20.4.69) from 192.168.1.10 em1: 56(84) bytes of data.
> 64 bytes from pub2.kernel.org (149.20.4.69): icmp_seq=1 ttl=42 time=202 ms
> 64 bytes from pub2.kernel.org (149.20.4.69): icmp_seq=2 ttl=42 time=187 ms
> ^C
>
> Works as expected.
>
> I know that binding to loopback probably doesn't make much sense, but I think
> that ping should be able to cope with that.

I think it would be wrong if ping worked as you suggest.  Binding to an
interface means use that interface as the source of your packets, and having
it bind hard helps when using systems with multiple NICs on same subnet
(or possibly, same IP).

> Also, it would be nice to mention the difference between -I <ip> and -I <iface>
> in the manpage.

In my opinion, -I <iface> should use SO_BINDTODEVICE, but at least in
older versions of ping it did not.

Thanks,
Ben

>
> I don't understand the problem clearly enough to write a patch.
>
> Regards,
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
