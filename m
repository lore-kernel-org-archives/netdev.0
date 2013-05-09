From: Cong Wang <amwang@redhat.com>
Subject: Re: Regression: too many packets with incorrect checksum
Date: Thu, 09 May 2013 17:17:43 +0800
Message-ID: <1368091063.12413.9.camel@cr0>
References: <1368013888.3115.9.camel@cr0> <1368088578.12413.4.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13643 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752698Ab3EIJRs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 May 2013 05:17:48 -0400
In-Reply-To: <1368088578.12413.4.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-09 at 16:36 +0800, Cong Wang wrote:
> 
> Running another RHEL6 KVM guest, it doesn't have this problem, so it is
> not related with KVM environment.

I thought it might be due to tcpdump receives a packet which is
checksummed partially while the wire receives a correct one, but netperf
shows that is wrong, apparently it hurts performance:

With latest -net:

~% netperf -4 -H 192.168.122.74
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
192.168.122.74 () port 0 AF_INET
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    10.20     105.19


With a RHEL6 kernel:

~% netperf -4 -H 192.168.122.101
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
192.168.122.101 () port 0 AF_INET
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    10.00    5528.64
