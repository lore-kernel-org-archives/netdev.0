From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] acenic - don't spin in hard_start_xmit when ring fills
Date: Fri, 17 Sep 2004 09:02:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040917090217.43483d10@dell_ss3.pdx.osdl.net>
References: <20040916161753.37254cbd@dell_ss3.pdx.osdl.net>
	<20040916162250.5b7cfa85.davem@davemloft.net>
	<20040916164206.707204d4@dell_ss3.pdx.osdl.net>
	<20040916165042.362a3e79.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jes@wildopensource.com, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040916165042.362a3e79.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 16 Sep 2004 16:50:42 -0700
"David S. Miller" <davem@davemloft.net> wrote:

> On Thu, 16 Sep 2004 16:42:06 -0700
> Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> > NO, the bus just isn't fast enough to keep up with the number of small
> > packets I am shoving at it.
> > 
> > You got TX_LOCKED and TX_BUSY confused. The problem is drivers that
> > don't check to see if the last packet sent fills the ring and stop
> > themselves.
> 
> I understand.
> 
> But that still makes this change buggy.  I believe the two choices
> are:
> 
> 1) Accept this spinning performance characteristic of the
>    acenic driver.

What if there is buggy, hardware that never drains the ring.
It can happen.

> 2) Finally give up on acenic's clever lockless scheme and add
>    the necessary locking + start/stop tx flow control so it
>    will never have to return TX_BUSY except in absolutely
>    catastrophic failure cases.

I'll code up a non-lockless version and see if makes any real difference.
