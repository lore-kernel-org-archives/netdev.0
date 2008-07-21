From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Subject: Re: [crash] BUG: unable to handle kernel NULL pointer dereference
 at 0000000000000370
Date: Tue, 22 Jul 2008 00:04:43 +0200
Message-ID: <488507FB.9050101@trash.net>
References: <4884F3D7.4070604@lwfinger.net>	<20080721.134608.75595942.davem@davemloft.net>	<4884F6E9.6090809@trash.net> <20080721.140120.135667045.davem@davemloft.net> <4884FA3F.70109@trash.net> <48850121.9090106@trash.net> <488504D9.5090100@lwfinger.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080609000902030105010805"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, mingo-X9Un+BFzKDI@public.gmane.org,
	ischram-CNXmb7IdZIWZIoH1IeqzKA@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	j@w1.fi
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <488504D9.5090100-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080609000902030105010805
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Larry Finger wrote:
> Patrick McHardy wrote:
>>
>> This is what I was missing, we're setting a lockdep class
>> by default depending on dev->type. This patch combined
>> with yours should fix all addr_list_lock warnings.
>
> No cigar yet. I tried davem's patch first, then yours on top of his. I 
> still get both the recursive locking and the kernel warning.

Does this one earn me my cigar? :)



--------------080609000902030105010805
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/core/dev.c b/net/core/dev.c
index 2eed17b..371b1a0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -259,7 +259,7 @@ static RAW_NOTIFIER_HEAD(netdev_chain);
 
 DEFINE_PER_CPU(struct softnet_data, softnet_data);
 
-#ifdef CONFIG_DEBUG_LOCK_ALLOC
+#ifdef CONFIG_LOCKDEP
 /*
  * register_netdevice() inits txq->_xmit_lock and sets lockdep class
  * according to dev->type

--------------080609000902030105010805--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
