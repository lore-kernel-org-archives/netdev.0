From: Rick Jones <rick.jones2@hp.com>
Subject: Re: A performance regression of gretap
Date: Wed, 10 Jul 2013 08:18:37 -0700
Message-ID: <51DD7B4D.3060509@hp.com>
References: <327738182.1491147.1373450503005.JavaMail.root@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pravin B Shelar <pshelar@nicira.com>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:33904 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434Ab3GJPSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 11:18:39 -0400
In-Reply-To: <327738182.1491147.1373450503005.JavaMail.root@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/10/2013 03:01 AM, Cong Wang wrote:
> Hi, Pravin
>
> I just noticed the performance over gretap is very bad,
> which is probably caused by your GRE refactor patches.
>
> See below:
>
> # netperf -4 -H 192.168.2.1
> MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.2.1 () port 0 AF_INET
> Recv   Send    Send
> Socket Socket  Message  Elapsed
> Size   Size    Size     Time     Throughput
> bytes  bytes   bytes    secs.    10^6bits/sec
>
>   87380  16384  16384    14.01       0.02
>
> Could you please take a look? And, gre tunnel is fine, this
> problem only exists for gretap. I reviewed the gretap code,
> but can't find any bug.
>
> It is very easy to reproduce, just setup a gretap device
> on both ends, and run netperf over it.

One way to provide more information from the netperf level in future 
endeavours would be to extend the command line a bit:

netperf -4 -H 192.168.2.1 -c -C -- -o 
throughput,local_sd,remote_ds,local_transport_retrans

and then again sans gretap.  The -c/-C and [local|remote]_sd would be to 
show the difference in path length, local_transport_retrans to see what 
sort of difference there is in retransmissions.

happy benchmarking,

rick jones
