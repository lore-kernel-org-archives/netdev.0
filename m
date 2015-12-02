From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: ipsec impact on performance
Date: Tue, 1 Dec 2015 16:56:24 -0800
Message-ID: <565E41B8.1080206@cumulusnetworks.com>
References: <20151201175953.GC21252@oracle.com> <565DE446.2070609@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Rick Jones <rick.jones2@hpe.com>,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	netdev@vger.kernel.org, linux-crypto@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33255 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932196AbbLBA41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 19:56:27 -0500
Received: by pabfh17 with SMTP id fh17so22809517pab.0
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 16:56:26 -0800 (PST)
In-Reply-To: <565DE446.2070609@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/1/15 10:17 AM, Rick Jones wrote:
> On 12/01/2015 09:59 AM, Sowmini Varadhan wrote:
>> But these are all still relatively small things - tweaking them
>> doesnt get me significantly past the 3 Gbps limit. Any suggestions
>> on how to make this budge (or design criticism of the patch) would
>> be welcome.
>
> What do the perf profiles show?  Presumably, loss of TSO/GSO means an
> increase in the per-packet costs, but if the ipsec path significantly
> increases the per-byte costs...
>
> Short of a perf profile, I suppose one way to probe for per-packet
> versus per-byte would be to up the MTU.  That should reduce the
> per-packet costs while keeping the per-byte roughly the same.

Using iperf3 and AH with NULL algorithm between 2 peers connected by a 
10G link.

Without AH configured I get a steady 9.9 Gbps with iperf3 consuming 
about 55% cpu.

With AH I get ~1.5 Gbps with MTU at 1500:

[  4]   0.00-1.01   sec   160 MBytes  1.33 Gbits/sec   23    905 KBytes
[  4]   1.01-2.00   sec   211 MBytes  1.79 Gbits/sec    0    996 KBytes

iperf3 runs about 60% CPU and ksoftirqd/2 is at 86%.


Bumping the MTU to 9000:

[  4]   3.00-4.00   sec   914 MBytes  7.67 Gbits/sec  260   1.01 MBytes
[  4]   4.00-5.00   sec  1012 MBytes  8.49 Gbits/sec    0   1.23 MBytes
[  4]   5.00-6.00   sec  1.15 GBytes  9.88 Gbits/sec    0   1.23 MBytes

At this rate iperf3 was at 95% CPU and ksoftirqd was not relevant.
