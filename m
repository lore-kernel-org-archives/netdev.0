From: Jim Keniston <jkenisto@us.ibm.com>
Subject: Re: [PATCH 1/4] Net device error logging, revised
Date: Wed, 03 Sep 2003 13:56:23 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <3F565577.3A98BA17@us.ibm.com>
References: <3F4A8027.6FE3F594@us.ibm.com> <20030826183221.GB3167@kroah.com> <3F4BEE68.A6C862C2@us.ibm.com> <3F4BF265.5050101@pobox.com> <3F4C046D.77CF7E03@us.ibm.com> <3F562590.60101@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@oss.sgi.com>,
	"Feldman, Scott" <scott.feldman@intel.com>,
	Larry Kessler <kessler@us.ibm.com>,
	Randy Dunlap <rddunlap@osdl.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Andrew Morton <akpm@osdl.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> 
> Jim Keniston wrote:
> > Jeff Garzik wrote:
> ...
> >>A separate "NETIF_MSG_ALL" test is not needed, because msg_enable is a
> >>bitmask.  A msg_enable of 0xffffffff will naturally create a NETIF_MSG_ALL.
> >
> >
> > But how do you code a netdev_* call where you ALWAYS want the message (including
> > netdev_printk-style prefix) logged, regardless of the value of msg_enable?  That's
> > what NETIF_MSG_ALL is for (and why it might be better called NETIF_MSG_ALWAYS)...
> 
> I understand the purpose of NETIF_MSG_ALL; re-read what I said.  You
> don't need a separate _test_, as your implementation includes.  Defining
> NETIF_MSG_ALL to 0xffffffff will naturally create the effect you seek.
>

So the test becomes
	if (netdev->msg_enable & msglevel) { /* log message */ }
If netdev->msg_enable == 0, the message is suppressed even if msglevel == NETIF_MSG_ALL.
I had intended that "ALL" would override the msg_enable setting (even 0), but we can do
it this way as well.

> ...
> 
>         Jeff

Jim
