From: Daniel Drake <dsd@gentoo.org>
Subject: Re: d80211-drivers pull request (week-48)
Date: Mon, 11 Dec 2006 20:07:32 -0500
Message-ID: <457E00D4.7010201@gentoo.org>
References: <200612110101.58710.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Ulrich Kunitz <kune@deine-taler.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp121.iad.emailsrvr.com ([207.97.245.121]:51940 "EHLO
	smtp121.iad.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750802AbWLLBH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Dec 2006 20:07:26 -0500
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200612110101.58710.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Wu wrote:
>       zd1211rw-d80211: Use ieee80211_tx_status

I've thought some more about this and I'm not so sure that this is the 
right approach.

Can't devicescape be taught that the ZD1211 handles retries in hardware 
and the stack doesn't need to worry about it?

What does devicescape do in response to not getting an ack? Does it 
retransmit? If that is all then it doesn't need to be at stack level, 
since the hardware handles that on its own, and we can configure that to 
behave the same way as the stack would.

I think I remember reading that devicescape uses failed transmission 
rate in the rate adjustment calculations. Even without this racy ack 
system we can still achieve that - the device tells us every time it 
retries a transmit, and then it sends a special interrupt at the end 
saying that all retries failed.

Daniel

