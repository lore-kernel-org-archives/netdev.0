From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] softmac: remove netif_tx_disable when scanning
Date: Sun, 26 Nov 2006 23:13:25 -0500
Message-ID: <456A65E5.1010902@gentoo.org>
References: <4568DCEB.mailLLK1Z24PM@lwfinger.net>	
	<45691273.9090803@gentoo.org>
	<1164535408.21459.3.camel@johannes.berg>	
	<4569C2D0.8080406@gentoo.org>
	<1164559882.22909.5.camel@johannes.berg>	
	<4569DC33.8050208@gentoo.org>
	<1164566436.22909.26.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
In-Reply-To: <1164566436.22909.26.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
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

Johannes Berg wrote:
> On Sun, 2006-11-26 at 13:25 -0500, Daniel Drake wrote:
> 
>> No, we could stick with our existing setup if the stack did something 
>> different.
> 
> But you do need full refcounting I guess.

No, I don't think we would need to move away from our existing method:

   spin_lock_irqsave(&mac->lock, flags);
   if (mac->updating_rts_rate == 0 && mac->updating_basic_rates == 0)
     netif_wake_queue(mac->netdev);
   spin_unlock_irqrestore(&mac->lock, flags);

That said, it is in some ways comparable to refcounting without a 
counter: if both flags are set to 0, the above code is guaranteed to be 
executed twice (each time after one flag is toggled)

Daniel
