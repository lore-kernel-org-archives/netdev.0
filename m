From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 1/4] Net device error logging, revised
Date: Tue, 26 Aug 2003 18:06:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030826180626.50778705.shemminger@osdl.org>
References: <3F4A8027.6FE3F594@us.ibm.com>
	<20030826183221.GB3167@kroah.com>
	<3F4BEE68.A6C862C2@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, LKML <linux-kernel@vger.kernel.org>,
   netdev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>,
   "Feldman, Scott" <scott.feldman@intel.com>,
   Larry Kessler <kessler@us.ibm.com>, Randy Dunlap <rddunlap@osdl.org>,
   Alan Cox <alan@lxorguk.ukuu.org.uk>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jim Keniston <jkenisto@us.ibm.com>
In-Reply-To: <3F4BEE68.A6C862C2@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 
> The following options come to mind:
> 1. Keep the msg buffer, but make it smaller.  Around 120 bytes would probably be
> big enough for the vast majority of messages.  (printk() uses a 1024-byte buffer,
> but it's static -- see #2.)
> 
> 2. Use a big, static buffer, protected by a spinlock.  printk() does this.
> 
> 3. Do the whole thing in a macro, as in previous proposals.  The size of the macro
> expansion could be reduced somewhat by doing the encode-prefix step in a function --
> something like:
> 
> #define netdev_printk(sevlevel, netdev, msglevel, format, arg...)	\
> do {									\
> if (NETIF_MSG_##msglevel == NETIF_MSG_ALL || ((netdev)->msg_enable & NETIF_MSG_##msglevel)) {	\
> 	char pfx[40];							\
> 	printk(sevlevel "%s: " format , make_netdev_msg_prefix(pfx, netdev) , ## arg);	\
> }} while (0)
> 
> This would make your code bigger, but not that much bigger for the common case where
> the msglevel is omitted (and the 'if(...)' is optimized out).

Is there some way to tack copy and prepend what you want onto the format
string, and add additional arguments to the call to printk?  That way you
wouldn't need space for the potentially large resulting string, but only
enough room for the expanded format string.
