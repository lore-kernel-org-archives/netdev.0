From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: acenic lockup
Date: Wed, 7 May 2003 21:06:32 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200305071706.VAA00295@mops.inr.ac.ru>
References: <20030506.234316.68138442.davem@redhat.com>
Mime-Version: 1.0
Cc: anton@samba.org, jes@trained-monkey.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20030506.234316.68138442.davem@redhat.com> from "David S. Miller" at May 6, 3 11:43:16 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

>    Its stuck there and never coming out. Alexey: I have a feeling you
>    wrote this code, is that correct? :)

Yes, I did. I am not sure about barriers, I stopped attempts
to understand this long ago. Anyway, intel does not have anything
to put here, mb() at side updating pointer looks enough.
 

There is a real ugly BUG in the driver, ace_watchdog():

 	} else {
		printk(KERN_DEBUG "%s: BUG... transmitter died. Kicking it.\n",
		       dev->name);
#if 0
		netif_wake_queue(dev);
#endif
	}

(#if is from my local tree). I remember we discussed this with Dave
and he was very angry about this flaw shared by most of drivers and, seems,
did not eat this fix.

So, if you see the message, it is surely this bug.


Alexey
