From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [patch]: CONFIG_IPV6_SUBTREES fix for MIPv6
Date: Fri, 13 Jun 2003 20:26:58 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030613202652.1d64ed6f.nakam@linux-ipv6.org>
References: <3EE5F85E.9080006@tml.hut.fi>
	<20030610.095135.28806569.davem@redhat.com>
	<3EE6ECD3.6050103@tml.hut.fi>
	<20030611.202003.74721468.davem@redhat.com>
	<3EE83D81.5030605@tml.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, lpetande@morphine.tml.hut.fi,
   yoshfuji@linux-ipv6.org, vnuorval@tcs.hut.fi, kuznet@ms2.inr.ac.ru,
   netdev@oss.sgi.com, ajtuomin@morphine.tml.hut.fi, jagana@us.ibm.com,
   kumarkr@us.ibm.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Henrik Petander <lpetande@tml.hut.fi>
In-Reply-To: <3EE83D81.5030605@tml.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 12 Jun 2003 11:44:49 +0300
Henrik Petander <lpetande@tml.hut.fi> wrote:

> > No it doesn't. When you startup zebra, it may flush the entire
> > routing table.
> 
> 
> I don't see a problem in that. It would only result in a short period of 
> missing mipv6 route optimization information, until MIPv6 daemon 
> reinserted the mipv6 information. MIPv6 daemon would do this after 
> getting a notification of the deletion of the old mipv6 related cached 
> routes. This would relate to zebra in the same way as pmtu discovery.

When routing information is deleted by zebra, the packets from user
application will be sent incorrectly until MIPv6 daemon re-inserts
the special host route.

Anyway, in the xfrm based approach, 

I suggested that MIPv6 should use the same policy as IPsec(racoon),
however, it causes problems as David and Henrik said.

So, I suggest a little other plan like below:
How about making new policy(MIPv6 policy) in the similar way of IPsec?
MIPv6 and IPsec policy are managed by separated list.

In that way we have to notice about both of policies and state order
in looking xfrm up or creating bundle.
I think there is not period issue like above.

I think, in networking operation, it seems natural way to use stackable
destination, and Henrik's patch(mip6-exthdr.patch;maybe sent to netdev at 5 Jun)
is almost the same one.

The first step is we should have two kinds of policy, IPsec and MIP6.
In this step, we make MIP6 stack to use stackable destination and some XFRM 
with MIP6 policy.
Probably the second step will be to modify xfrm_policy is not a IPsec's SPD but
generic one.

How about you?

Regards,

-- 
Masahide NAKAMURA
