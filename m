From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few KB/s
Date: Thu, 21 Nov 2013 23:55:09 +0100
Message-ID: <87txf54b76.fsf@natisbad.org>
References: <1384869194.8604.92.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131119174323.GH913@1wt.eu>
	<1384885910.8604.110.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131119184121.GN913@1wt.eu> <874n780wzc.fsf@natisbad.org>
	<20131120191145.GP8581@1wt.eu> <87txf692zx.fsf@natisbad.org>
	<20131120215435.GT8581@1wt.eu> <20131121004430.GX8581@1wt.eu>
	<871u298lv6.fsf@natisbad.org> <20131121215259.GE18513@1wt.eu>
	<1385071201.10637.69.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	simon.guinot@sequanux.org, netdev@vger.kernel.org,
	edumazet@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
	linux-arm-kernel@lists.infradead.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:50325 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753406Ab3KUWzd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Nov 2013 17:55:33 -0500
Received: from smtp.natisbad.org (unknown [81.57.185.249])
	by smtp3-g21.free.fr (Postfix) with ESMTP id BBEC6A60ED
	for <netdev@vger.kernel.org>; Thu, 21 Nov 2013 23:55:21 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi eric,

Eric Dumazet <eric.dumazet@gmail.com> writes:

>> > I tested it on my RN2120 (2-core armada XP): I got no problem and the
>> > link saturated w/ apache, nginx and netperf. Good work!
>> 
>> Great, thanks for your tests Arnaud. I forgot to mention that all my
>> tests this evening involved this patch as well.
>
> Now you might try to set a lower value
> for /proc/sys/net/ipv4/tcp_limit_output_bytes

On the RN2120, for a file served from /run/shm (for apache and nginx):

          Apache     nginx       netperf
131072:  102 MB/s   112 MB/s   941.11 Mb/s
 65536:  102 MB/s   112 MB/s   935.97 Mb/s
 32768:  101 MB/s   105 MB/s   940.49 Mb/s
 16384:   94 MB/s    90 MB/s   770.07 Mb/s
  8192:   83 MB/s    66 MB/s   556.79 Mb/s

On the RN102, this time for apache and nginx, the file is served from
disks (ext4/lvm/raid1):

          Apache     nginx       netperf
131072:  66 MB/s   105 MB/s   925.63 Mb/s
 65536:  59 MB/s   105 MB/s   862.55 Mb/s
 32768:  62 MB/s   105 MB/s   918.99 Mb/s
 16384:  65 MB/s   105 MB/s   927.71 Mb/s
  8192:  60 MB/s   104 MB/s   915.63 Mb/s

Values above are for a single flow though.

Cheers,

a+
