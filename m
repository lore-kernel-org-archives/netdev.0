From: "David S. Miller" <davem@redhat.com>
Subject: Re: 2.6: QoS scheduling not working with IP-over-IP
Date: Wed, 11 Feb 2004 21:51:42 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040211215142.7f817513.davem@redhat.com>
References: <Pine.LNX.4.44.0402101324350.810-100000@atlantis.knm.org.pl>
	<20040211200549.736fa8b3.davem@redhat.com>
	<1076561489.1032.65.camel@jzny.localdomain>
	<1076561998.1035.72.camel@jzny.localdomain>
	<1076562282.1033.76.camel@jzny.localdomain>
	<20040211211536.23e97997.davem@redhat.com>
	<1076563502.1031.85.camel@jzny.localdomain>
	<1076564638.1033.91.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: qnex@atlantis.knm.org.pl, netdev@oss.sgi.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1076564638.1033.91.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 12 Feb 2004 00:43:59 -0500
jamal <hadi@cyberus.ca> wrote:

> On Thu, 2004-02-12 at 00:25, jamal wrote:
> 
> > > OK, however, old behavior would be like setting tx_queue_len to '1'.
> > > Do we wish to preserve this?
> 
> I think i misunderstood you - you are saying maybe it was not a bug
> after all in pfifo, right? i.e the off by one is ok.

No, you understood me the first time.

I am saying, the PFIFO fix was correct.  And therefore if we are to preserve
the tunnel device behavior precisely to what happened before the PFIFO fix
we must set the tx_queue_len to '1'.

What use is any other value?  Show me a code path where more than one packet
can occupy the queue of one of these tunnel devices? :-)

Packets get headers added and straight to transmit to next device.
->hard_start_xmit() routines of these drivers always consume SKB and
return 0.
