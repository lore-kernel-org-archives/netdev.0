From: Daniel Drake <dsd@gentoo.org>
Subject: Re: zd1211 ported to Devicescape stack
Date: Sat, 02 Dec 2006 10:58:13 -0500
Message-ID: <4571A295.4030700@gentoo.org>
References: <200612020316.50965.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ulrich Kunitz <kune@deine-taler.de>, netdev@vger.kernel.org,
	John Linville <linville@tuxdriver.com>,
	Luis Rodriguez <mcgrof@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp131.iad.emailsrvr.com ([207.97.245.131]:15816 "EHLO
	smtp131.iad.emailsrvr.com") by vger.kernel.org with ESMTP
	id S1759466AbWLBQFp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Dec 2006 11:05:45 -0500
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200612020316.50965.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Wu wrote:
> Hi,
> 	I have finished a port of the zd1211 driver to the Devicescape 802.11 stack. 

Yeah!! thanks so much for doing this.

Are you willing to maintain this in terms of porting upcoming patches to 
it? I think I also speak for Ulrich when I say that at the moment we are 
more concerned about getting our work into mainline and don't have time 
to maintain a ported driver, but we will be happy to switch immediately 
as soon as devicescape is declared ready for mainline inclusion.

> 	- The original driver does not seem to check if a frame has been successfully 
> TXed (as in RXed an ACK), so the port does not properly report to the stack 
> whether or not a TX succeeded.

Indeed, the situation is that silence means transmission succeeded, and 
we get a retry_failed interrupt if it didn't.

> 	- d80211 doesn't tell us the size of the next fragment, so that part of the 
> hardware TX header isn't set anymore. This might be fixed in the future.

Even though ieee80211 appeared to have the infrastructure to do so, I 
don't think it was ever passing us multiple fragments. So this is no big 
deal.

> 	- The LED link status isn't too reliable - I haven't found a way to reliably 
> tell if the upper layer thinks it is associated, and I don't know how to use 
> the LED api. Not too worried about this issue though.

Watch out, the single most common bug report for zd1211rw (vs vendor 
driver) was that the LED didn't blink until recently :)

Thanks!
Daniel

