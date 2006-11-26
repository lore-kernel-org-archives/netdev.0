From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH] softmac: remove netif_tx_disable when scanning
Date: Sun, 26 Nov 2006 14:06:57 +0100
Message-ID: <200611261406.58149.mb@bu3sch.de>
References: <4568DCEB.mailLLK1Z24PM@lwfinger.net>
	<200611261312.20442.mb@bu3sch.de> <4569912C.1000506@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
In-Reply-To: <4569912C.1000506-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Content-Disposition: inline
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

On Sunday 26 November 2006 14:05, Larry Finger wrote:
> Michael Buesch wrote:
> > On Sunday 26 November 2006 11:03, Johannes Berg wrote:
> >> On Sat, 2006-11-25 at 23:05 -0500, Daniel Drake wrote:
> >>
> >>> Surely disabling the queue actually makes sense, in order to avoid 
> >>> frames designated for the "current session" being transmitted on 
> >>> different channels during scanning?
> >> The problem is that queue disabling isn't refcounted so that a scan that
> >> collides with bcm43xx having disabled the queue for calibration might
> >> re-enable the queue while bcm43xx is still calibrating.
> >>
> >> Clearly, this doesn't fully fix the problem because softmac will try to
> >> transmit frames during the calibration. Hence, a proper fix would be to
> >> not remove the calls to netif_tx_disable but make them go through
> >> softmac (ieee80211_tx_disable) to make sure that softmac doesn't try to
> >> scan while the queues are disabled, which would fix the aforementioned
> >> problem of softmac enabling the queue while the driver needs it disabled
> >> for free.
> > 
> > Yeah, but I don't think it's worth fixing. ;)
> > Simply removing this tx_disable in softmac fixes a _big_ bug
> > and that must be applied. The bug of being able to scan while
> > calibrating is very minor and not worth to fix. Fixing this
> > will likely introduce other bugs. It's simply not worth it
> > anymore.
> 
> I actually found one of these while testing WX locking as suggested by Dan Williams. His method has 
> two scripts running at the same time with one of them doing an 'iwlist ethX scan' and the other 
> executing an 'iwconfig ethX' as fast as possible. Running this test for 36 hours failed to indicate 
> any locking errors, but running it without the patch under discussion led to a number of the 
> following errors:
> 
> kernel: bcm43xx: ASSERTION FAILED (!ring->suspended) at: 
> drivers/net/wireless/bcm43xx/bcm43xx_dma.c:71:request_slot()
> 
> This error _NEVER_ happened when softmac was not allowed to disable TX.

Yeah, that's the error I expected.
Nice that you proved my point for this being an important patch. ;)

-- 
Greetings Michael.
