From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [crash] BUG: unable to handle kernel NULL pointer dereference
 at 0000000000000370
Date: Mon, 21 Jul 2008 16:51:21 -0500
Message-ID: <488504D9.5090100@lwfinger.net>
References: <4884F3D7.4070604@lwfinger.net>	<20080721.134608.75595942.davem@davemloft.net>	<4884F6E9.6090809@trash.net> <20080721.140120.135667045.davem@davemloft.net> <4884FA3F.70109@trash.net> <48850121.9090106@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, mingo-X9Un+BFzKDI@public.gmane.org,
	ischram-CNXmb7IdZIWZIoH1IeqzKA@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	j@w1.fi
To: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <48850121.9090106-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Patrick McHardy wrote:
>> David Miller wrote:
>>> Maybe something like the following should do it?
>>
>>
>> It looks correct in any case. I'm not sure whether it fixes
>> this lockdep warning though, according to the backtrace and
>> module list its b43 and dev_mc_sync in net/mac80211/main.c
>> that are causing the error, which don't seem to be included
>> in your patch. I'm unable to find where it previously
>> initialized the xmit_lock lockdep class though, so I must
>> be missing something :)
> 
> This is what I was missing, we're setting a lockdep class
> by default depending on dev->type. This patch combined
> with yours should fix all addr_list_lock warnings.

No cigar yet. I tried davem's patch first, then yours on top of his. I still get 
both the recursive locking and the kernel warning.

BTW, wireless doesn't work but if I plug in the wire, then networking is OK. It 
seems to be in mac80211, which is strange because I routinely run the latest 
wireless-testing kernel, and all the wireless bits should be there already.

I'm still plugging away at the bisection. I think I got away from the kernel 
that won't build.

Larry
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
