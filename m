From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/4] Net device error logging, revised
Date: Tue, 26 Aug 2003 19:51:01 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <3F4BF265.5050101@pobox.com>
References: <3F4A8027.6FE3F594@us.ibm.com> <20030826183221.GB3167@kroah.com> <3F4BEE68.A6C862C2@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@oss.sgi.com>,
	"Feldman, Scott" <scott.feldman@intel.com>,
	Larry Kessler <kessler@us.ibm.com>,
	Randy Dunlap <rddunlap@osdl.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Andrew Morton <akpm@osdl.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Jim Keniston <jkenisto@us.ibm.com>
In-Reply-To: <3F4BEE68.A6C862C2@us.ibm.com>
List-Id: netdev.vger.kernel.org

Jim Keniston wrote:
> #define netdev_printk(sevlevel, netdev, msglevel, format, arg...)	\
> do {									\
> if (NETIF_MSG_##msglevel == NETIF_MSG_ALL || ((netdev)->msg_enable & NETIF_MSG_##msglevel)) {	\
> 	char pfx[40];							\
> 	printk(sevlevel "%s: " format , make_netdev_msg_prefix(pfx, netdev) , ## arg);	\
> }} while (0)
> 
> This would make your code bigger, but not that much bigger for the common case where
> the msglevel is omitted (and the 'if(...)' is optimized out).


"NETIF_MSG_" is silly and should be eliminated.
A separate "NETIF_MSG_ALL" test is not needed, because msg_enable is a 
bitmask.  A msg_enable of 0xffffffff will naturally create a NETIF_MSG_ALL.

Also, whatever mechanism is created, it needs to preserve the feature of 
the existing system:

	if (a quick bitmask test)
		do something

And preferably "do something" is not inlined, because printk'ing -- 
although it may appear in a fast path during debugging -- cannot be 
considered a fast path itself.

	Jeff
