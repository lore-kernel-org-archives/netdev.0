From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] bcm43xx: further fix for periodic work errors
Date: Sat, 23 Sep 2006 14:06:57 -0500
Message-ID: <451585D1.3080102@lwfinger.net>
References: <4514B322.mail1K91A36N8@lwfinger.net>
	<200609230956.05475.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>,
	Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
In-Reply-To: <200609230956.05475.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
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
> On Saturday 23 September 2006 06:08, Larry Finger wrote:
>> Recent changes in the setup for preemptible periodic work fixed most
>> of the problems with NETDEV watchdog timeouts; however, some variants
>> of the bcm43xx device still had the problem. These were fixed by setting
>> the parameter MAXIMUM_BADNESS to 0. By doing so, all the functionality
>> associated with calculating the 'badness' of the upcoming periodic work
>> is no longer needed; therefore it is removed.
> 
> Uhm, no. Wait. _Why_ does the watchdog trigger.
> All periodic work in the fastpath (which you remove with this patch)
> is supposed to execute in a few microseconds.
> I don't think we want to fix this my removing the fastpath and always
> taking the _expensive_ slowpath periodic work.
> 
> So why does the watchdog trigger for the fast periodic work?
> We need to find out.
> Removing the fastpath is just bad for overall latency.
> 
> The two fastpath periodic works are 15 and 30, if executed
> standalone. If the 15 and/or 30 is execiuted alongside with
> a 60sec work, it's all slowpath, of course.

I was thinking that the 15 second periodic work called mac suspend, which is the most expensive part 
of the slowpath, but I see that is an unlikely condition. I'm now testing to see if moving the 
netif_tx_disable/netif_wake_queue pair into all paths fixes the errors. Those calls should be 
relatively inexpensive.

Larry
