From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: bcm43xx regression 2.6.19rc3 -> rc5, rtnl_lock trouble?
Date: Thu, 16 Nov 2006 16:40:59 -0600
Message-ID: <455CE8FB.2000803@lwfinger.net>
References: <455B63EC.8070704@madrabbit.org> <455BFC47.3020006@madrabbit.org>
	<455CAB2F.1060709@lwfinger.net> <200611162016.42095.mb@bu3sch.de>
	<455CBDD7.6000507@madrabbit.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Ray Lee <ray-lk-0Cg02Ec9UG4BXFe83j6qeQ@public.gmane.org>
In-Reply-To: <455CBDD7.6000507-0Cg02Ec9UG4BXFe83j6qeQ@public.gmane.org>
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

Ray Lee wrote:
> 
> If I could figure out a way to make it repeatable, I'd happily do a blind
> bisect. As it stands, I can't trigger it manually. I've got a while true; do
> iwconfig eth1; done running to hit the ioctls (as the trace in my first
> message showed one of them in use), but that's might be a red herring. After
> this email, I'll be shutting down all my browser and email windows to try to
> kill the large network traffic generating apps as well. Also, does the 0x812
> core only hit for certain access points? I have a b and 2 b/g's in range.
> 
> So, barring me finding a way to reproduce it, there's the good news that
> there's only three bcm43xx patches between what worked and what didn't:
> 
> ray@phoenix:~/work/kernel/linux-2.6$ hg log -I drivers/net/wireless/bcm43xx -r
> v2.6.19-rc3:tip
> changeset:   40500:4ef6746b2f06
> user:        Al Viro <viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org>
> date:        Wed Oct 25 12:01:11 2006 +0700
> summary:     [PATCH] missing include of dma-mapping.h
> 
> changeset:   40964:ca97546422bd
> user:        Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
> date:        Wed Nov 01 08:15:40 2006 +0500
> summary:     [PATCH] bcm43xx: Fix low-traffic netdev watchdog TX timeouts
> 
> changeset:   40965:f5021f3521c2
> user:        Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
> date:        Wed Nov 01 08:15:41 2006 +0500
> summary:     [PATCH] bcm43xx: fix unexpected LED control values in BCM4303 sprom
> 
> I think we can safely rule out a #include addition. The LED control values one
> should be harmless too, yes? So I'm at a loss as to how it could be anything
> but the middle one.
> 
> I'm open to suggestions on how to make the problem trigger more than once
> every two days...

I don't know what might be causing the lock problems. I'm more concerned with the NETDEV WATCHDOG 
timeouts. AFAIK, you are the only one still reporting this error. On my system, I get an occasional 
MAC suspend failure, sometimes followed by an BCM43xx_IRQ_XMIT_ERROR.

 From what I read in your post, the timeouts happen a lot more often than once every two days. Once 
we get those fixed, then we can concentrate on the locking.

Larry
