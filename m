From: Christoph Lameter <cl@linux.com>
Subject: Re: udp ping pong measurements from 2.6.22 to .30 with various cpu
 affinities
Date: Fri, 24 Apr 2009 10:23:45 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904231334460.21619@qirst.com>
References: <alpine.DEB.1.10.0904221604480.18138@qirst.com> <49EF85E3.8060703@cosmosbay.com> <alpine.DEB.1.10.0904221700030.32682@qirst.com> <49F09F84.10108@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:33832 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753153AbZDXOcW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2009 10:32:22 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 7678D82C284
	for <netdev@vger.kernel.org>; Fri, 24 Apr 2009 10:43:03 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id vSXxtMId7-bw for <netdev@vger.kernel.org>;
	Fri, 24 Apr 2009 10:43:03 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 488F482C288
	for <netdev@vger.kernel.org>; Fri, 24 Apr 2009 10:42:57 -0400 (EDT)
In-Reply-To: <49F09F84.10108@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for the late response but somehow it got stuck.

On Thu, 23 Apr 2009, Eric Dumazet wrote:

> For example, "cat /proc/cpuinfo", just to be sure you did not invert cpus,
> since your results are not that logical.

We confirmed that there is an issue with processors (32/64 bit
different was surprising).... Rerunning tests to have the proper l2 cache
sharing.

> "size vmlinux-2.6.2[2-9] vmlinux-2.6.30" to check how kernel text size increase.
> We add new features, security knobs, fixes, ... and this probably increase number
> of instructions taken in a particular workload, who knows ?

-rw-r--r-- 1 root   root    2770952 2009-04-02 14:40 vmlinuz-2.6.22
-rw-r--r-- 1 root   root    2681816 2009-04-06 18:44 vmlinuz-2.6.23
-rw-r--r-- 1 root   root    2314872 2009-04-06 18:46 vmlinuz-2.6.24
-rw-r--r-- 1 root   root    2358584 2009-04-06 18:48 vmlinuz-2.6.25
-rw-r--r-- 1 root   root    2392144 2009-04-06 18:49 vmlinuz-2.6.26
-rw-r--r-- 1 root   root    2438656 2009-04-06 18:52 vmlinuz-2.6.27
-rw-r--r-- 1 root   root    2518400 2009-04-06 18:53 vmlinuz-2.6.28
-rw-r--r-- 1 root   root    2553024 2009-04-06 18:55 vmlinuz-2.6.29
-rw-r--r-- 1 root   root    2579392 2009-04-16 11:19 vmlinuz-2.6.30-rc2

> What was the size of packets used on this last test ?

40 bytes
>
> iptables active or not ? conntrack ?

no conntrack not iptables.

> Using NO_HZ mode gives higher latencies

CONFIG_NO_HZ is set

