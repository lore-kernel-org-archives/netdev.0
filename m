From: Asim Shankar <asimshankar@gmail.com>
Subject: netif_rx_schedule_prep() returning false?
Date: Wed, 2 Feb 2005 12:04:38 -0600
Message-ID: <7bca1cb5050202100475279073@mail.gmail.com>
Reply-To: Asim Shankar <asimshankar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

In NAPI related drivers, is it expected that netif_rx_schedule_prep()
will return false? Does the fact that it returns false mean something
is wrong?

Specifically, in e1000 driver, when loaded with TxIntDelay=0,
RxIntDelay=0, InterruptThrottleRate=0 (i.e., no hardware
interrupt-coalescing), I've observed that the call to
netif_rx_schedule_prep() in the interrupt handler (e1000_intr())
ocassionally returns false. Further investigation shows that this is
because the __LINK_STATE_RX_SCHED bit of the struct net_device's state
is already set (netif_running(dev) is always true). I also checked the
interrupt cause register (ICR) in the interrupt handler and it seems
the interrupts were caused by packet receives (ICR == E1000_ICR_RXT0,
no other bits in the ICR register were set), which by my understanding
should have not been possible.

In other words, it seems the device is already scheduled for polling
when a receive-related interrupt is received and handled.

Is this behavior normal?

Thanks,

-- Asim
