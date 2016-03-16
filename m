From: Anna Fischer <a.fischer@sirrix.com>
Subject: ksoftirqd and network processing
Date: Wed, 16 Mar 2016 20:57:33 +0100
Message-ID: <56E9BAAD.101@sirrix.com>
References: <56E98F4C.4000004@sirrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.sirrix.com ([176.9.214.66]:45171 "EHLO mx.sirrix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965553AbcCPUX5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 16:23:57 -0400
Received: from [172.25.20.101] (helo=exchange2010.sirrix.de)
	by mx.sirrix.com with esmtps (TLS1.0:RSA_AES_128_CBC_SHA1:16)
	(Exim 4.76)
	(envelope-from <a.fischer@sirrix.com>)
	id 1agHYN-0005BU-LJ
	for netdev@vger.kernel.org; Wed, 16 Mar 2016 20:56:23 +0100
In-Reply-To: <56E98F4C.4000004@sirrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi there,

I'd like to understand more in detail how ksoftirqd works in combination
with Linux kernel networking.

I'm doing IPSec processing on my Linux machine (kernel 4.4). On one
interface I receive encrypted packets which are decrypted and then
routed out plaintext (TCP) via another interface. Now I can
see that ksoftirqd runs at 100% CPU. Furthermore, I see that initially
it runs on core 0, then after a few seconds, it switches over to core 1
and runs at 100%, then switches over to core 2, and so on.

I have two questions:

1) I assume it switches cores because the kernel thread is scheduled on
different cores, depending on where the softirqs happen. Why does the
load never scale across cores? As far as I understand softirqs can run
concurrently on different cores. So why does it not scale?

2) Is it normal that ksoftirqd runs at such a high CPU load when doing
IPSec, if the core is a small core with small frequency (Intel Atoms,
for example)? And if so, is there any way to optimize this for IPSec?

3) When I pin RX queue interrupts of the NIC to certain cores, I can see
that interrupts are really only processed on that core. However, it does
not change anything about the ksoftirqd behavior. Should it not match,
how I route interrupts?

Many thanks,
Anna
