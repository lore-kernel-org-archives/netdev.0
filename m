From: jamal <hadi@cyberus.ca>
Subject: Re: bk16 changes to cbq
Date: 07 Jul 2004 14:11:32 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089223892.1026.309.camel@jzny.localdomain>
References: <1088861810.1039.298.camel@jzny.localdomain>
	 <20040705202727.GA21226@ms2.inr.ac.ru>
	 <20040706221317.2f0585d1.davem@redhat.com>
	 <20040707155958.GA9797@ms2.inr.ac.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, shemminger@osdl.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20040707155958.GA9797@ms2.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-07-07 at 11:59, Alexey Kuznetsov wrote:
> Hello!
> 
> > e1000 would hang the delay scheduler sometimes
> > 
> > Let me look for the exact email from Stephen.  Here it is:
> > 
> > http://mailman.ds9a.nl/pipermail/lartc/2004q2/012736.html
> 
> Well, that test was really meaningless. So, Stephen's patch is right.

Not totaly Alexey. Its like you said before, the code there was an
optimization.
Heres a scenario especialy with drivers returning 0 on everything
in their txmit() (discussion going elsewhere with Jeff Garzik):

Driver does netif_queue_stop() because of full ring and returns 0.
qdisc gets called and it decides to throttle. In that case if it starts
watchdog (because it doesnt look at device state). 
That would be two possible future reschedules of device.
One because of qdisc throttle timer and another because of netif_stop.
Its not much code difference or cpu cycles, but still an optimization
for that case.
OTOH, this would not happen if the driver returned a 1 along with skb
(the way e1000 does).

cheers,
jamal
