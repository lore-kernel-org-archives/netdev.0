From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [crash] BUG: unable to handle kernel NULL pointer dereference
 at 0000000000000370
Date: Mon, 21 Jul 2008 16:15:17 -0700 (PDT)
Message-ID: <20080721.161517.27161039.davem@davemloft.net>
References: <488504D9.5090100@lwfinger.net>
	<488507FB.9050101@trash.net>
	<4885104A.2070201@lwfinger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, ischram-CNXmb7IdZIWZIoH1IeqzKA@public.gmane.org,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, j@w1.fi
To: Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4885104A.2070201-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Date: Mon, 21 Jul 2008 17:40:10 -0500

> Sorry :(
> 
> I used the davem patch, the second version of your first one, and your second 
> one. Both problems persist.
> 
> Still plugging away on bisection.

GIT bisecting the lockdep problem is surely going the land you on:

commit e308a5d806c852f56590ffdd3834d0df0cbed8d7
Author: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Date:   Tue Jul 15 00:13:44 2008 -0700

    netdev: Add netdev->addr_list_lock protection.
    
    Add netif_addr_{lock,unlock}{,_bh}() helpers.
    
    Use them to protect operations that operate on or read
    the network device unicast and multicast address lists.
    
    Also use them in cases where the code simply wants to
    block calls into the driver's ->set_rx_mode() and
    ->set_multicast_list() methods.
    
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
