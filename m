From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/4] [NETLINK] introduce netlink_check_skb function
Date: Fri, 11 Feb 2005 23:43:54 +0100
Message-ID: <20050211224354.GE31837@postel.suug.ch>
References: <420BF8CB.6080005@eurodev.net> <20050211032448.GD31837@postel.suug.ch> <420D243C.4090507@eurodev.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>
To: Pablo Neira <pablo@eurodev.net>
Content-Disposition: inline
In-Reply-To: <420D243C.4090507@eurodev.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> They are all the same thing. They all return 16 bytes which is the size 
> of a netlink header. If you and someone else think that those are more 
> readable, I'm ok with it, whatever. I just stole that piece of code as 
> is from current checkings done in xfrm and rtnetlink.

That's absolutely true, my point is that while reading that line
of code it reads like while the remaining length in the socket buffer
is still greather or equal than the total message size until the next
message with a payload of 0, then do something. It looks confusing at
a first glance because you're not event interested in the payload just
now. A choice of NLMSG_ALIGN(sizeof(*nlh)) or NLMSG_LENGTH(0) clearly
points out that you're just checking for enough room regarding the
netlink header in order to access it safely and do the real sanity
check against the complete message length. Engross that thought a bit
further, NLMSG_SPACE could change at some point assuming that it is
only used in contexts where the total message size is in question.

If you think that's too much of nitpicking, then forget about it. It's
technicaly absolutely correct at the moment.
