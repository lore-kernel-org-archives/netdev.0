From: jamal <hadi@cyberus.ca>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Tue, 20 Apr 2010 08:02:21 -0400
Message-ID: <1271764941.3735.94.camel@bigi>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271268242.16881.1719.camel@edumazet-laptop>
	 <1271271222.4567.51.camel@bigi>
	 <20100415.014857.168270765.davem@davemloft.net>
	 <1271332528.4567.150.camel@bigi>  <4BC741AE.3000108@hp.com>
	 <1271362581.23780.12.camel@bigi>
	 <n2p412e6f7f1004151656q5f3f2cbeh324a859b88688398@mail.gmail.com>
	 <1271395106.16881.3645.camel@edumazet-laptop>
	 <1271424065.4606.31.camel@bigi>
	 <1271489739.16881.4586.camel@edumazet-laptop>
	 <1271525519.3929.3.camel@bigi>
	 <1271583573.16881.4798.camel@edumazet-laptop>
	 <1271590476.16881.4925.camel@edumazet-laptop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>, Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org, robert@herjulf.net, andi@firstfloor.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:49229 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753711Ab0DTMC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 08:02:26 -0400
Received: by pwj9 with SMTP id 9so4100531pwj.19
        for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 05:02:26 -0700 (PDT)
In-Reply-To: <1271590476.16881.4925.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

folks,

Thanks to everybody (Eric stands out) for your patience. 
I ended mostly validating whats already been said. I have a lot of data
and can describe in details how i tested etc but it would require
patience in reading, so i will spare you;-> If you are interested let me
know and i will be happy to share.

Summary is: 
-rps good, gives higher throughput for apps
-rps not so good, latency worse but gets better with higher input rate
or increasing number of flows (which translates to higher pps)
-rps works well with newer hardware that has better cache structures.
[Gives great results on my test machine a Nehalem single processor, 4
cores each with two SMT threads that has a shared L2 between threads and
a shared L3 between cores]. 
Your selection of what the demux cpu is and where the target cpus are is
an influencing factor in the latency results. If you have a system with
multiple sockets, you should get better numbers if you stay within the
same socket relative to going across sockets.
-rps does a better job at helping schedule apps on same cpu thus
localizing the app. The throughput results with rps are very consistent
and better whereas in non-rps case, variance is _high_.

My next step is to do some forwarding tests - probably next week. I am
concerned here because i expect the cache misses to be higher than the
app scenario (netdev structure and attributes could be touched by many
cpus)

cheers,
jamal

