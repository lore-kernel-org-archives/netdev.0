From: Petr Vandrovec <vandrove@vc.cvut.cz>
Subject: assertion (dev->qdisc_list == NULL) failed at net/sched/sch_generic.c(530)
Date: Wed, 24 Sep 2003 18:11:52 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030924161152.GA8683@vana.vc.cvut.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,
  today I noticed that I'm getting assertion below from 2.6.0-test5-xxx
kernel from monday when I shut down vmnet. After looking at the code
I found that with CONFIG_NET_SCHED disabled there is nobody who would
clear dev->qdisc_list... Code which removes dev from the qdisc_list in
the qdisc_destroy is inside CONFIG_NET_SCHED, and I see no other code
which could clear qdisc_list...

Is this assertion just bogus for CONFIG_NET_SCHED unset, or qdisc_destroy
should not depend on CONFIG_NET_SCHED, or am I missing something in the 
vmnet initialization? It just uses ether_setup(), register_netdev() on
initialization, and unregister_netdev() on module unload.

# insmod vmnet; netifup vmnet1; ifconfig vmnet1 1.2.3.4 up
/dev/vmnet: open called by PID 7413 (vmnet-netifup)
/dev/vmnet: port on hub 1 successfully opened
# ifconfig vmnet1 down
# rmmod vmnet
KERNEL: assertion (dev->qdisc_list == NULL) failed at net/sched/sch_generic.c(530)

						Thanks,
							Petr Vandrovec
							vandrove@vc.cvut.cz
