From: Daniel Drake <dsd@gentoo.org>
Subject: Re: d80211-drivers pull request (week-48)
Date: Mon, 11 Dec 2006 22:51:16 -0500
Message-ID: <457E2734.6010700@gentoo.org>
References: <200612110101.58710.flamingice@sourmilk.net> <457E00D4.7010201@gentoo.org> <200612112120.58157.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Ulrich Kunitz <kune@deine-taler.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp141.iad.emailsrvr.com ([207.97.245.141]:56788 "EHLO
	smtp141.iad.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751075AbWLLDv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Dec 2006 22:51:27 -0500
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200612112120.58157.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Wu wrote:
> I don't think this race is such a big deal. It will only happen when someone 
> is really trying to mess with the link, and would cause the rate control to 
> jump to the highest speed. However, if someone is really trying to mess with 
> the link this way, the stability of the link is in trouble anyways. Wait for 
> stations to send frames, and send an ack for every unicast frame - everyone 
> will get confused. To actually mess with this code, the attacker would have 
> to transmit acks nearly continuously as it can't tell exactly when is a good 
> time to screw things up, and the driver recovers as soon as the queue is 
> emptied. Someone transmitting all the time is a problem for all wireless 
> cards. :)

It's ugly, in my mind not necessary, and it will kill performance. We 
haven't had to make such compromises in a long time. We got a large TX 
speed boost when the driver was modified to queue up multiple transmit 
URBs (i.e. don't wait for URB completion of the first) at the same time 
early during driver development. And even with that we're still a fair 
distance from the performance of the vendor driver.

While the stack isn't so well suited for this device I'd much prefer to 
see a more simplistic workaround. For example, assume all packets were 
successful but then report a failure when an interrupt comes in. Or, if 
the stack won't accept out-of-the-blue notifications like that, then 
maintain a counter which is incremented when a failure is reported, and 
when transmitting the next few frames report them as failed and 
decrement the counter (while counter > 0). Maybe disable rate control 
until we can come up with a nicer solution.

Daniel
