From: "David S. Miller" <davem@redhat.com>
Subject: Re: NAPI note
Date: Mon, 17 Feb 2003 18:57:19 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030217.185719.28797590.davem@redhat.com>
References: <3E4D66DF.3040800@colorfullife.com>
	<3E4D8295.2050400@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manfred@colorfullife.com, zaitcev@redhat.com, jbourne@mtroyal.ab.ca,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
In-Reply-To: <3E4D8295.2050400@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Jeff Garzik <jgarzik@pobox.com>
   Date: Fri, 14 Feb 2003 18:58:13 -0500

   Manfred Spraul wrote:
   > It seems to be a generic NAPI restriction:
   > The caller of netif_receive_skb() must not own a spinlock that is 
   > acquired from an interrupt handler.
   
   Thanks much for noticing this, Manfred.

I think this logic is buggy.

In the example I've seen posted, only a NAPI implementation bug
could cause the situation to occur.

If cpu1 is in ->poll() for the driver, then by definition the
device shall not cause interrupts.  The device's interrupts
are disabled before we enter the ->poll() handler, and as such
the "cpu2 take device interrupt and takes driver->lock" cannot
occur.

If anything we've found a bug in interrupt disabling in the tg3
driver.
