From: "David S. Miller" <davem@redhat.com>
Subject: Re: Oops on bootup.
Date: Thu, 08 May 2003 10:27:55 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030508.102755.25135206.davem@redhat.com>
References: <20030508112531.0483fccf.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030508112531.0483fccf.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Thu, 8 May 2003 11:25:31 -0700

   This happened once and is not reproducible.
   There appears to be initialization window where netlink data can
   arrive before socket slab cache is initialized or something like that.
   Probably a packet has to arrive at just the right time or something similar.
   
It's oopsing on sock_inode_cachep.  We init that in sock_init()
which is invoked explicitly by do_basic_setup().

The calltrace is back into netlink_kernel_create via rtnetlink_init
via netlink_proto_init.  netlink_proto_init was recently changed
into a subsys initcall.

Because it is a subsys initcall, it must be invoked after sock_init()
and therefore the sock_inode_cachep must be initialized properly at
this point.

I have no idea how your trace is possible besides possible mem
corruption.
