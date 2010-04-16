From: jamal <hadi@cyberus.ca>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Fri, 16 Apr 2010 10:43:45 -0400
Message-ID: <1271429025.4606.149.camel@bigi>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <20100415.014857.168270765.davem@davemloft.net>
	 <1271332528.4567.150.camel@bigi>  <4BC741AE.3000108@hp.com>
	 <1271362581.23780.12.camel@bigi>
	 <n2p412e6f7f1004151656q5f3f2cbeh324a859b88688398@mail.gmail.com>
	 <1271395106.16881.3645.camel@edumazet-laptop>
	 <1271424065.4606.31.camel@bigi>
	 <k2h412e6f7f1004160634v88440075p6e4cb2404abdb006@mail.gmail.com>
	 <1271425753.4606.65.camel@bigi>
	 <r2q412e6f7f1004160710j6d575f36t8e39a283328cf2d7@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-fhaWjb9pvEosrbCXOKDS"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org, robert@herjulf.net, andi@firstfloor.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:42972 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753696Ab0DPOnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 10:43:50 -0400
Received: by ewy20 with SMTP id 20so896375ewy.1
        for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 07:43:47 -0700 (PDT)
In-Reply-To: <r2q412e6f7f1004160710j6d575f36t8e39a283328cf2d7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-fhaWjb9pvEosrbCXOKDS
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Fri, 2010-04-16 at 22:10 +0800, Changli Gao wrote:
> On Fri, Apr 16, 2010 at 9:49 PM, jamal <hadi@cyberus.ca> wrote:

> > my observation is:
> > s->total is the sum of all packets received by cpu (some directly from
> > ethernet)
> 
> It is meaningless currently. If rps is enabled, it may be twice of the
> number of the packets received, because one packet may be count twice:
> one in enqueue_to_backlog(), and the other in __netif_receive_skb(). 

You are probably right - you made me look at my collected data ;->
i will look closely later, but it seems they are accounting for
different cpus, no? 
Example, attached are some of the stats i captured when i was running
the tests redirecting from CPU0 to CPU1 1M packets at about 20Kpps (just
cut to the first and last two columns):

cpu   Total     |rps_recv |rps_ipi
-----+----------+---------+---------
cpu0 | 002dc7f1 |00000000 |000f4246
cpu1 | 002dc804 |000f4240 |00000000
-------------------------------------

So: cpu0 receive 0x2dc7f1 pkts accummulative over time and
redirected to cpu1 (mostly, the extra 5 maybe to leftover since i clear
the data) and for the test 0xf4246 times it generated an IPI. It can be
seen that total running for CPU1 is 0x2dc804 but in this one run it
received 1M packets (0xf4240). 
i.e i dont see the double accounting..

cheers,
jamal

--=-fhaWjb9pvEosrbCXOKDS
Content-Disposition: attachment; filename="st1"
Content-Type: text/plain; name="st1"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

002dc7f1 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 000f4246
002dc804 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 000f4240 00000000
00000004 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000004 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000006 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
0000003c 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000004 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
0000003e 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000

--=-fhaWjb9pvEosrbCXOKDS--

