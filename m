From: Chris Wright <chrisw@osdl.org>
Subject: [RFC][PATCH 0/3] netlink check sender
Date: Sat, 12 Feb 2005 01:01:09 -0800
Message-ID: <20050212010109.V24171@build.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jmorris@redhat.com, sds@epoch.ncsc.mil,
        serue@us.ibm.com
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The following patches are for comment.  They introduce a new callback
to enable netlink messages to be validated in the sender's context,
and then convert a couple kernel netlink receivers to use this callback.
This eliminates the need to copy the sender's effective capabilities into
the netlink control buffer.  It also allows the audit system to manage
the loginuid in the kernel without adding more fields to netlink_skb_parms
or requiring special case netlink code.  I think this would obsolete the
security_netlink_recv hook, and simplify the security_netlink_send hook.

Currently I've only hooked the unicast messages, because I didn't think
any of the kernel netlink input functions would be processing broadcast
messages (perhaps I missed something).

I didn't move the logic that simply ignores messages (e.g. type <
RTM_BASE), but I did move the logic that looks for invalid messages
(e.g. type > RTM_MAX) to the check_sender callback.

Thoughts?

thanks,
-chris
-- 
Linux Security Modules     http://lsm.immunix.org     http://lsm.bkbits.net
