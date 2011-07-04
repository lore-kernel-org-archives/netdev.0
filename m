From: jamal <hadi@cyberus.ca>
Subject: Re: libpcap and tc filters
Date: Mon, 04 Jul 2011 09:05:40 -0400
Message-ID: <1309784740.26180.21.camel@mojatatu>
References: <CAA0qwj6fWJFVCDW9M9jZhvQnSTy=Pnyp0AhWFYT8FOiroq7C=Q@mail.gmail.com>
	 <1309777908.26180.1.camel@mojatatu>
	 <CAA0qwj70-qUQ+6NL=2LP05TyMN99MdL1BF8tko+v=DhdyjZjJQ@mail.gmail.com>
	 <CAA0qwj7cH8Ah69fBMkXpGkwG77TH_ZqMhKwj-Cc8Vc=F5c9SSw@mail.gmail.com>
Reply-To: jhs@mojatatu.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Adam Katz <adamkatz0@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:39063 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756898Ab1GDNFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2011 09:05:48 -0400
Received: by iyb12 with SMTP id 12so4427630iyb.19
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2011 06:05:47 -0700 (PDT)
In-Reply-To: <CAA0qwj7cH8Ah69fBMkXpGkwG77TH_ZqMhKwj-Cc8Vc=F5c9SSw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-07-04 at 15:37 +0300, Adam Katz wrote:
> here's a more concrete example:
> 
> An example configuration:
> 
> 	sudo tc qdisc add dev eth1 root handle 1: prio priomap 2 2 2 2 2 2 2
> 2 2 2 2 2 2 2 2 2
> 	sudo tc qdisc add dev eth1 parent 1:1 handle 10: pfifo 	
> 	sudo tc qdisc add dev eth1 parent 1:2 handle 20: pfifo
> 	sudo tc qdisc add dev eth1 parent 1:3 handle 30: pfifo
> 	sudo tc filter add dev eth1 protocol ip parent 1: prio 1 u32 match ip
> dport 22 0xffff flowid 1:1
> 	sudo tc filter add dev eth1 protocol ip parent 1: prio 1 u32 match ip
> sport 22 0xffff flowid 1:1
> 	sudo tc filter add dev eth1 protocol ip parent 1: prio 2 u32 match ip
> dport 80 0xffff flowid 1:2
> 	sudo tc filter add dev eth1 protocol ip parent 1: prio 2 u32 match ip
> sport 80 0xffff flowid 1:2


looks fine.

> I then used scp to copy a small file between computers while capturing
> with wireshark:
> 
> http://dl.dropbox.com/u/3237005/port22example.pcap
> 
> and later I replayed the same capture using tcpreplay.
> When using scp, the packets once again ended up where they should be
> (1:1 in this configuration). With tcpreplay they ended up in the
> default 1:3

Where is the capture from tcpreplay? What i was asking is you validate
that the capture before and what is sent out by tcprelay look the same.
Can you please do that?
It is possible because your filters are not matched they end up on your
default queue based on tos value.

If you have your kernel compiled with CONFIG_CLS_U32_PERF you should
see when the filters get hit as well
(do something like sudo tc -s filter ls dev eth1)


cheers,
jamal



