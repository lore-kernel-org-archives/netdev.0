From: John Heffner <jheffner@psc.edu>
Subject: loopback interface and soft irqs
Date: Thu, 3 Apr 2003 22:22:03 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.NEB.4.33.0304032157340.9380-100000@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I'm using 2.4.20, and I noticed that when doing an all-out tcp transfer
over the loopback interface, the machine was actually spending lots of
time in the idle loop.  I looked at the device code and after
loopback_xmit() calls netif_rx(), the softirq does not get run.  I added a
do_softirq() call at the end of loopback_xmit() and CPU utilization went
up to 100% throughput significantly increased (about 2x).

Is there a good reason for not running the soft irq here?

Thanks,
  -John
