From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Fix erratic behavior in rt6_dump_route()
Date: Mon, 17 Nov 2003 18:50:50 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031117185050.1cd10877.davem@redhat.com>
References: <Pine.LNX.4.58.0311171155050.21177@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.58.0311171155050.21177@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 17 Nov 2003 12:11:52 +0200 (EET)
Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:

> I noticed some erratic behavior when doing "ip -6 r". I traced the problem
> to rt6_dump_route() where we typecast NLMSG_DATA() to a rtmsg without
> checking the size of the netlink message first. Seems like ip only passes
> a rtgenmsg to the kernel when it does a dump, so we end up reading pure
> garbage when we interpret it as a rtmsg. Please apply the patch!

Let's discuss this a little bit. :)

I believed that these lengths are supposed to be verified at one level
higher, in net/core/rtnetlink.c, see "rtm_min[]".

Well, it doesn't do this length verification on dumps.
I can only assume this is intentional.  Ok, I see, cases
like ipv4 check the length properly so it is clear that
this is required.

I will apply your patch.
