From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC] tcp ephemeral port selection
Date: Mon, 25 Oct 2004 16:34:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041025163418.30c703e2.davem@redhat.com>
References: <20041011171422.65f88472@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20041011171422.65f88472@zqx3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 11 Oct 2004 17:14:22 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Here is a test patch which changes how TCP ephemeral ports are
> selected from a simple roving pointer to:
> 	* net_random() as starting point when doing pure local
>         searchs.
> 	* use md hash (like isn) when doing connection based
>         assignments with a rover
> 
> This is *not* for 2.6.9 but wanted to get it out for comment for
> future versions.

I'm not totally against this kind of idea at all.

I hope we don't run into situations with the new
code where we don't actually check the whole port
range due to some logic error or similar.

Another thing we need to eventually do is allow
allocation into the local port space more completely.
Even if every local port has one user, we could still
allocate some ports if the daddr/dport is known and
is different from the existing user.
