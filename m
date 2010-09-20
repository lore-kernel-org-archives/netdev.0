From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: E1000E/82567LM-3: link reported up too soon
Date: Mon, 20 Sep 2010 20:57:46 +0200
Message-ID: <878w2wnsyd.fsf@small.ssi.corp>
References: <87pqwff2bd.fsf@small.ssi.corp> <4C90EDF3.8010401@hp.com>
	<87bp7vnnpj.fsf@small.ssi.corp>
	<20100920.112213.42810338.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: brian.haley@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:46775 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753262Ab0ITS5H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Sep 2010 14:57:07 -0400
In-Reply-To: <20100920.112213.42810338.davem@davemloft.net> (David Miller's
	message of "Mon, 20 Sep 2010 11:22:13 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

David Miller <davem@davemloft.net> writes:

> From: arno@natisbad.org (Arnaud Ebalard)
> Date: Sat, 18 Sep 2010 16:14:16 +0200
>
>> Below, UMIP is configured w/o any additional delay before RS emission on
>> that interface. No DHCP running either:
>> 
>> 15:40:22.984311 ethertype IPv6 (0x86dd), length 62: :: > ff02::2: ICMP6, router solicitation, length 8
>> 15:40:26.984845 ethertype IPv6 (0x86dd), length 62: :: > ff02::2: ICMP6, router solicitation, length 8
>> 15:40:26.989264 ethertype IPv6 (0x86dd), length 158: fe80::224:d5ff:fed4:476c > ff02::1: ICMP6, router advertisement
>> 
>> David, any idea on where this may come from and how to track the cause?
>
> I have no context, what's the exact problem?

On some ethernet devices (at least), link may be reported up (NEWLINK
received by userspace with flags indicating UP and RUNNING) before the
interface is really usable. When sending packets as soon as the link is
available, the first one may be dropped. That's what you see on the
capture above.

I think all the details are in the first message of the thread:

  http://www.spinics.net/lists/netdev/msg140916.html

I started adding printk in net/core/dev.c and net/sched/sch_generic.c
and I am now in e1000e code ... I will report what I found if it's
interesting.

Cheers,

a+
