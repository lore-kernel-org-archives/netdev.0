From: James Morris <jmorris@redhat.com>
Subject: Netlink Connector / CBUS
Date: Tue, 5 Apr 2005 01:05:10 -0400 (EDT)
Message-ID: <Xine.LNX.4.44.0504050030230.9273-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, <netdev@oss.sgi.com>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>, <rml@novell.com>,
	Greg KH <greg@kroah.com>, Andrew Morton <akpm@osdl.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261562AbVDEFGE@vger.kernel.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy,

Please send networking patches to netdev@oss.sgi.com.

Your connector code (under drivers/connector) is now in the -mm tree and 
as far as I can tell, has not received any review from the network 
developers.

Looking at it briefly, it seems quite unfinished.

I'm not entirely sure what it's purpose is.

A clear explanation of its purpose would be helpful (to me, at least), as 
well as documentation of the API and majore data structures (which akpm 
has also asked for, IIRC).

I can see one example of where it's being used with kobject_uevent, and it 
seems to have arrived via Greg-KH's I2C tree...

If you're trying to add a generic, psuedo-reliable Netlink communication 
system, perhaps this should be built into Netlink itself as an extension 
of the existing Netlink API.

I don't think this should be done as a separate "driver" off somewhere 
else with a new API.


A few questions:

- Why does it by default use NETLINK_NFLOG a kernel socket, and also allow 
this to be overriden by a module parameter?

- Why does the cn.o module (poor namespace choice) add a callback itself
on initialization?

- Where is the userspace code which uses this?  I checked out dbus from 
cvs and couldn't see anything obvious.


Thanks,


- James
-- 
James Morris
<jmorris@redhat.com>
