From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] common code for generating tcp_info
Date: Mon, 07 Jun 2004 07:48:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1086619698.4113.22.camel@localhost.localdomain>
References: <20040604153749.5d8a13b9@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David S Miller <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040604153749.5d8a13b9@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-06-04 at 15:37, Stephen Hemminger wrote:

> diff -Nru a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
> --- a/net/ipv4/tcp_diag.c	2004-06-04 15:35:55 -07:00
> +++ b/net/ipv4/tcp_diag.c	2004-06-04 15:35:55 -07:00
> +void tcp_get_info(struct sock *sk, struct tcp_info *info)

What is the appropriate text to update tcp.h?

	/* The syn_wait_lock is necessary only to avoid tcp_get_info having
	 * to grab the main lock sock while browsing the listening hash
	 * (otherwise it's deadlock prone).
	 * This lock is acquired in read mode only from tcp_get_info() and
	 * it's acquired in write mode _only_ from code that is actively
	 * changing the syn_wait_queue. All readers that are holding
	 * the master sock lock don't need to grab this lock in read mode
	 * too as the syn_wait_queue writes are always protected from
	 * the main sock lock.
	 */
