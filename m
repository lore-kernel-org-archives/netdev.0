From: "Wesley W. Terpstra" <terpstra@gkec.tu-darmstadt.de>
Subject: Broken? 2.6.6 + IP_ADD_SOURCE_MEMBERSHIP + SO_REUSEADDR
Date: Fri, 4 Jun 2004 17:54:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040604155423.GA5656__31495.9009564065$1086368069@muffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
Resent-Message-Id: <20040605.015327.131480818.yoshfuji@linux-ipv6.org>
To: linux-kernel@vger.kernel.org
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi!

I am using the new IGMPv3 support in the 2.6.* series for Single Source
Multicast (SSM). However, the kernel appears to (incorrectly) drop packets
in some situations.

What I do is this: open a UDP port, set it SO_REUSEADDR, bind it to port
6767, and then use IP_ADD_SOURCE_MEMBERSHIP to listen to multicast group 
232.65.43.21 and with a command-line controlled sender.

If I launch the same program twice with different senders, the first program
ceases to receive multicast packets. (Neither from its own sender, nor the
second program's sender) The second program receives packets from its
designated sender only (as expected).

I know from tcpdump that the switch is delivering messages from the first
designated sender. The kernel is simply not giving them to the application.

Some more observations:

If both programs specify the same sender, then both programs receive the
message (as expected).

This is not an issue with subscribing to multiple senders in general. A
single program listening to two senders does receive messages from both.

This seems like a bug to me.

PS. I am not subscribed to this list, so please CC me.

-- 
Wesley W. Terpstra
