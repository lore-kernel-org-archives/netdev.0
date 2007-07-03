From: "Veeraiyan, Ayyappan" <ayyappan.veeraiyan@intel.com>
Subject: RE: [PATCH] ixgbe: Introduce new 10GbE driver for Intel 82598 based PCI	Express adapters...
Date: Mon, 2 Jul 2007 17:08:42 -0700
Message-ID: <E35F4F4D7F6C9E4E826FEC1F86CEF583041934FE@orsmsx412.amr.corp.intel.com>
References: <20070702214238.GA7085@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Jeff Garzik" <jeff@garzik.org>, <netdev@vger.kernel.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	<arjan@linux.intel.com>, <akpm@linux-foundation.org>
To: "Christoph Hellwig" <hch@infradead.org>,
	"Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58108 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755226AbXGCAIo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2007 20:08:44 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070702214238.GA7085@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/2/07, Christoph Hellwig <hch@infradead.org> wrote:
> 
> But that'll require the single receiver queue version I guess.  The
> netdevice abuse is the only really major issue I see, although I'd of
> course really like to see the driver getting rid of the bitfield abuse
> aswell.

The submitted driver code supports single queue version in case of MSIX
allocation failures... As I said in the other mail, I feel, restricting
to single Rx queue in NAPI mode is better approach till Stephen's and
DaveM' work of separating NAPI from netdevice is done..

> Lots of drivers where the interface name is assigned after request_irq
> just use an internal name, e.g. ixgbeX in the case of this driver.
> 

This sounds ok to me. 

With this change, this is the output..

[root@ayyapsz src]# ip link
1: lo: <LOOPBACK,UP,10000> mtu 16436 qdisc noqueue
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: sit0: <NOARP> mtu 1480 qdisc noop
    link/sit 0.0.0.0 brd 0.0.0.0
3: eth6: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc pfifo_fast qlen
1000
    link/ether 00:50:8b:05:5f:95 brd ff:ff:ff:ff:ff:ff
29: eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc pfifo_fast qlen
1000
    link/ether 00:1b:21:01:e4:93 brd ff:ff:ff:ff:ff:ff
30: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop qlen 1000
    link/ether 00:1b:21:01:e4:92 brd ff:ff:ff:ff:ff:ff

[root@ayyapsz src]# cat /proc/interrupts | grep 29
214:          0          0   PCI-MSI-edge      ixgbe29-lsc
215:      11764      80213   PCI-MSI-edge      ixgbe29-rx7
216:      80257          0   PCI-MSI-edge      ixgbe29-rx6
217:      77331          0   PCI-MSI-edge      ixgbe29-rx5
218:      24201          0   PCI-MSI-edge      ixgbe29-rx4
219:      52911          0   PCI-MSI-edge      ixgbe29-rx3
220:     104591          0   PCI-MSI-edge      ixgbe29-rx2
221:      80249          8   PCI-MSI-edge      ixgbe29-rx1
222:         14          0   PCI-MSI-edge      ixgbe29-rx0
223:     194023     118220   PCI-MSI-edge      ixgbe29-tx0 

Ayyappan
