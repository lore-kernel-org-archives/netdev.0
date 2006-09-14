From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: netdev tx timeouts
Date: Wed, 13 Sep 2006 21:04:02 -0500
Message-ID: <4508B892.4040309@lwfinger.net>
References: <45076C00.2000100@lwfinger.net> <200609131430.53820.mb@bu3sch.de>
	<450806D1.4080809@lwfinger.net> <200609131549.23764.mb@bu3sch.de>
	<20060914102337.137d4591@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Stephen Hemminger <shemminger-3NddpPZAyC0@public.gmane.org>
In-Reply-To: <20060914102337.137d4591-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Wed, 13 Sep 2006 15:49:23 +0200
> Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org> wrote:
>> Simple. Reading the code of synchronize_net() and
>> netif_stop_queue() and thinking about why it breaks, instead
>> of committing bugfixes that only substitute one bug by another. ;)
>> I'll take a look, too.
> 
> Why are you doing the synchronize_net()? it is meant for RCU.

We know and it no longer is in the code. We have known for a couple of days that 
it was the synchronize_net() step that led to the netdev timeouts, but we were 
afraid that a bare netif_stop_queue would not be SMP safe. The current structure has

mutex_lock
netif_tx_disable(dev)   (equivalent to  netif_tx_lock_bh(dev);
				        netif_stop_queue(dev);
			                netif_tx_unlock_bh(dev);
spin_lock_irqsafe

I see you listed as a maintainer in several network-related parts of the system, 
so AFAIK, you are a network guru. Do you think this will work? I have tested 
code with just a netif_stop_queue (without the lock_bh/unlock_bh parts) on a UP 
system and have gotten no errors, but I do not have access to SMP hardware.

Thanks,

Larry
