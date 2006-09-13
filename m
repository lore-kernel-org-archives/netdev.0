From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: netdev tx timeouts
Date: Wed, 13 Sep 2006 08:25:37 -0500
Message-ID: <450806D1.4080809@lwfinger.net>
References: <45076C00.2000100@lwfinger.net> <200609131430.53820.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
In-Reply-To: <200609131430.53820.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
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

Michael Buesch wrote:
> On Wednesday 13 September 2006 04:25, Larry Finger wrote:
>> Michael,
>>
>> I still have not gotten a network guru to answer any questions about 
>> synchronize_net, but I have been testing the patch below:
> 
> I'd say this is racy.
> Did you test this on SMP?

No - I don't have the hardware.
> 
>> Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
>> ===================================================================
>> --- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
>> +++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
>> @@ -3169,8 +3169,8 @@ static void bcm43xx_periodic_work_handle
>>   		 * be preemtible.
>>   		 */
>>   		mutex_lock(&bcm->mutex);
>> -		netif_stop_queue(bcm->net_dev);
>>   		synchronize_net();
> 
> A TX handler starts on another CPU.
> 
>> +		netif_stop_queue(bcm->net_dev);
> 
> It's still running... boom.
> 

I see your point, but the current way breaks a UP system! What to do?

Larry
