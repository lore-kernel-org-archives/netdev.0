From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH V3 0/8] macvtap/vhost TX zero copy support
Date: Fri, 22 Apr 2011 10:52:53 -0700
Message-ID: <1303494773.10632.22.camel@localhost.localdomain>
References: <1303328216.19336.18.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:50169 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756407Ab1DVRxB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 13:53:01 -0400
In-Reply-To: <1303328216.19336.18.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-04-20 at 12:36 -0700, Shirley Ma wrote:
> I am collecting more test results against 2.6.39-rc3 kernel and will
> provide the test matrix later.

Single TCP_STREAM 120 secs test results over ixgbe 10Gb NIC results:

Message	BW(Gb/s)qemu-kvm (NumCPU)vhost-net(NumCPU) PerfTop irq/s
4K	7408.57		92.1%		22.6%		1229
4K(Orig)4913.17		118.1%		84.1%		2086	
8K	9129.90		89.3%		23.3%		1141
8K(Orig)7094.55		115.9%		84.7%		2157
16K	9178.81		89.1%		23.3%		1139
16K(Orig)8927.1		118.7%		83.4%		2262
64K	9171.43		88.4%		24.9%		1253
64K(Orig)9085.85        115.9%		82.4%		2229

For message size less or equal than 2K, there is a known KVM guest TX
overrun issue. With this zerocopy patch, the issue becomes more severe,
guest io_exits has tripled than before, so the performance is not good.
Once the TX overrun problem has been addressed, I will retest the small
message size performance.

Thanks
Shirley

