From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: acenic lockup
Date: Thu, 8 May 2003 02:21:11 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200305072221.CAA00973@mops.inr.ac.ru>
References: <20030507.123421.133894691.davem@redhat.com>
Mime-Version: 1.0
Cc: anton@samba.org, jes@trained-monkey.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20030507.123421.133894691.davem@redhat.com> from "David S. Miller" at May 7, 3 12:34:21 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> However, what does kick device back into working state?

Usually it is a link problem and device will recover after
link is restored. This happens here.

If it is some PCI failure or something went wrong in hardware,
the device will stop forever, I guess. And I guess this happens
with the same frequency as memory parity errors i.e. not so much. :-)


> Do we make shamans dance when this message hits the logs
> and pray for the best? :-) 

Sort of. I was about to dance for a while when saw creepy
"ethX: BUG, tx ring is full" from tulip, which has the same bogus
netif_wake_queue(). :-)

Well, full reset is difficult thing with lock-free acenic.
Seems, it has to throttle card, wake up something at process context,
to disable irq there and to reset nic like it happens at ifconfig down
(or even module unload in face of hard hardware failure?)

Alexey
