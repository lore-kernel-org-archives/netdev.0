From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] NETLINK: Use SKB_MAXORDER to calculate NLMSG_GOODSIZE
Date: Sun, 6 Feb 2005 22:25:22 -0800
Message-ID: <20050206222522.21492f5c.davem@davemloft.net>
References: <20050128230327.GV31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050128230327.GV31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 29 Jan 2005 00:03:27 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> NLMSG_GOODSIZE specifies a good default size for the skb tailroom
> used in netlink messages when the size is unknown at the time of
> the allocation.
> 
> The current value doesn't make much sense anymore because
> skb_shared_info isn't taken into account which means that
> depending on the architecture NLMSG_GOOSIZE can exceed PAGE_SIZE
> resulting in a waste of almost a complete page.
> 
> Using SKB_MAXORDER solves this potential leak at the cost of
> slightly smaller but safer sizes for some architectures.

Applied, to 2.4.x and 2.6.x, thanks Thomas.

This issue comes up again and again.  In the most recent
discussion I remember partaking in, I was trying to get it
so that all the code paths would calculate the size they
actually needed.  Most, if not all, are able to do so.
