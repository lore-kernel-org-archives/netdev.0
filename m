From: Tom Brown <sa212+glibc@cyconix.com>
Subject: Use of 802.3ad bonding for increasing link throughput
Date: Wed, 10 Aug 2011 13:07:53 +0100
Message-ID: <4E427499.8060108@cyconix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from queue02.mail.zen.net.uk ([212.23.3.27]:37231 "EHLO
	queue02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800Ab1HJNSF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2011 09:18:05 -0400
Received: from [212.23.3.142] (helo=smarthost03.mail.zen.net.uk)
	by queue02.mail.zen.net.uk with esmtp (Exim 4.72)
	(envelope-from <sa212+glibc@cyconix.com>)
	id 1Qr7Zw-0006IN-JL
	for netdev@vger.kernel.org; Wed, 10 Aug 2011 12:08:08 +0000
Received: from 82-70-243-134.dsl.in-addr.zen.co.uk ([82.70.243.134] helo=[127.0.0.1])
	by smarthost03.mail.zen.net.uk with esmtps (TLS-1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.63)
	(envelope-from <sa212+glibc@cyconix.com>)
	id 1Qr7Zp-0001YZ-FD
	for netdev@vger.kernel.org; Wed, 10 Aug 2011 12:08:01 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[couldn't thread with '802.3ad bonding brain damaged', as I've just 
signed up]

So, under what circumstances would a user actually use 802.3ad mode to 
"increase" link throughput, rather than just for redundancy? Are there 
any circumstances in which a single file, for example, could be 
transferred at multiple-NIC speed? The 3 hashing options are:

- layer 2: presumably this always puts traffic on the same NIC, even in 
a LAG with multiple NICs? Should layer 2 ever be used?

- layer2+3: can't be used for a single file, since it still hashes to 
the same NIC, and can't be used for load-balancing, since different IP 
endpoints go unintelligently to different NICs

- layer3+4: seems to have exactly the same issue as layer2+3, as well as 
being non-compliant

I guess my problem is in understanding whether the 802.3/802.1AX spec 
has any use at all beyond redundancy. Given the requirement to maintain 
frame order at the distributor, I can't immediately see how having a 
bonded group of, say, 3 NICs is any better than having 3 separate NICs. 
Have I missed something obvious?

And, having said that, the redundancy features seem limited. For hot 
standby, when the main link fails, you have to wait for both ends to 
timeout, and re-negotiate via LACP, and hopefully pick up the same 
lower-priority NIC, and then rely on a higher layer to request 
retransmission of the missing frame. Do any of you have any experience 
of using 802.1AX for anything useful and non-trivial?

So, to get multiple-NIC speed, are we stuck with balance-rr? But 
presumably this only works if the other end of the link is also running 
the bonding driver?

Thanks -

Tom

