From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: race in net/ipv4/ipip.c ?
Date: Wed, 12 Jan 2005 13:23:00 +0100
Message-ID: <20050112122300.GA12155@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi!

	static void ipip_tunnel_link(struct ipip_tunnel *t)
	{
		struct ipip_tunnel **tp = ipip_bucket(t);

		t->next = *tp;
		write_lock_bh(&ipip_lock);
		*tp = t;
		write_unlock_bh(&ipip_lock);
	}

Shouldn't the "t->next = *tp" be done inside the write lock?

A similar race exists in ipip_tunnel_unlink, and ip_gre seems to have
the same issues.


cheers,
Lennert
