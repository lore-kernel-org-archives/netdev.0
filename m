From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Locking model for NAPI drivers
Date: Wed, 01 Jun 2005 15:21:34 -0700 (PDT)
Message-ID: <20050601.152134.120445266.davem@davemloft.net>
References: <20050531.154847.63995530.davem@davemloft.net>
	<1117658019.4310.58.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mchan@broadcom.com
In-Reply-To: <1117658019.4310.58.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 01 Jun 2005 13:33:39 -0700

> I suppose we can enable interrupts in tg3_irq_quiesce() after setting
> the SYNC bit.

Since the caller shuts down NAPI ->poll(), after setting the SYNC bit
we can just check the MAILBOX register, and if a '1' is there just
return.  Does one need to mask out the upper bits of the regiser in
order to avoid seeing the IRQ tag in such a comparison?

Another potential problem is if the chip is hung for some reason,
and even though an interrupt is asserted it does not send the
interrupt.  We'd hang in this case as well.  Therefore it may be
wise to add a timeout to the COMPLETE bit polling loop in order
to handle such cases properly.
