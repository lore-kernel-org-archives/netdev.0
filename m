From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] bcm43xx: fix unexpected LED control values in BCM4303
	sprom
Date: Tue, 31 Oct 2006 22:34:20 -0600
Message-ID: <454823CC.9070808@lwfinger.net>
References: <4535AFC2.mail3S81JGSDJ@lwfinger.net>
	<200610181637.08698.mb@bu3sch.de>
	<20061101034936.GD9309@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
In-Reply-To: <20061101034936.GD9309-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
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

John,

I had not responded to Michael's comments as I heard from another user with thousands of these 
assertions in his logs, and I have been waiting for his sprom values and hoped to make a single 
patch. It is good, however, that you pushed the patch upstream.

John W. Linville wrote:
> On Wed, Oct 18, 2006 at 04:37:08PM +0200, Michael Buesch wrote:
> 
>>> @@ -257,7 +263,11 @@ void bcm43xx_leds_update(struct bcm43xx_
>>>  			continue;
>>>  #endif /* CONFIG_BCM43XX_DEBUG */
>>>  		default:
>>> -			assert(0);
>>> +			if (bcm43xx_max_led_err) {
>>> +				printkl(KERN_INFO PFX "Bad value in leds_update,"
>>> +					" led->behaviour: 0x%x\n", led->behaviour);
>>> +				--bcm43xx_max_led_err;
>>> +			}
>> I'd call this message bloat. ;) This is the first time the assertion
>> triggers since it was added.
>> You could instead remove the assert(), remove bcm43xx_max_led_err
>> and use dprintkl instead of printkl.

I disagree with part of Michael's comments. I think we should have a dprintk, rather than dprintkl, 
so that we get printouts from all four of the sprom values. That way the user will be able to report 
the numbers we need. As this would not limit the log entries and potentially generate thousands, 
there should be a variable like bcm43xx_max_led_err to limit the number of log entries.

I will propose a new patch once I get the data for the second case. In the meantime, the patch you 
have pushed upstream will fix the BCM4303 led assertions.

Larry
