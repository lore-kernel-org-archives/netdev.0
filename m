From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net/hsr: Add support for the High-availability Seamless
 Redundancy protocol (HSRv0)
Date: Tue, 25 Jun 2013 14:31:35 -0700
Message-ID: <1372195895.1245.89.camel@joe-AO722>
References: <51C87746.1010002@xdin.com> <1372097797.1245.12.camel@joe-AO722>
	 <51CA08B8.9030001@xdin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Javier Boticario <jboticario@gmail.com>,
	balferreira <balferreira@googlemail.com>
To: Arvid Brodin <arvid.brodin@xdin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:40101 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751490Ab3FYVbg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jun 2013 17:31:36 -0400
In-Reply-To: <51CA08B8.9030001@xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-06-25 at 23:16 +0200, Arvid Brodin wrote:
> On 2013-06-24 20:16, Joe Perches wrote:
> > On Mon, 2013-06-24 at 18:43 +0200, Arvid Brodin wrote:
> >> High-availability Seamless Redundancy ("HSR") provides instant failover
> >> redundancy for Ethernet networks. It requires a special network topology where
> >> all nodes are connected in a ring (each node having two physical network
> >> interfaces). It is suited for applications that demand high availability and
> >> very short reaction time.
> > 
> > trivia:
> > 
> > You should probably use checkpatch.pl --strict for files in net.
> > It will suggest aligning arguments in the more common net style.
> 
> Does this mean I should also remove spaces after casts (IMO this would reduce readability
> somewhat)?

No.  Don't do that adjustment if you don't want to.
checkpatch is just a stupid little tool, it's not dicta.
Weigh its recommendations according to your taste.

> I cannot judge if these files should go into include/net/ or not. Where can I get a final
> say on this?

David Miller is the most likely arbiter.

> Some of the definitions in hsr_netlink.h are needed by userspace tools that want to listen
> for ring errors etc from the HSR driver, so it would be a good thing if this file could be
> part of the kernel headers install. How can I accomplish this?

Maybe all those definitions are the CamelCase vars
and should go into a uapi #include?

include/uapi/linux/hsr_netlink.h should work.

> >> +bool is_hsr_master(struct net_device *dev)
> >> +{
> >> +	if (!dev) {
> >> +		WARN_ON_ONCE(1);
> >> +		return 0;
> >> +	}
> >> +	if (!dev->netdev_ops) {
> >> +		WARN_ON_ONCE(1);
> >> +		return 0;
> >> +	}
> > 
> > probably better to combine and give a textual reason
> 
> Or perhaps better to remove them altogether? I guess you could call them debug statements...

Better still if you know it's not possible anymore.

> >> diff --git a/net/hsr/hsr_main.h b/net/hsr/hsr_main.h
> > []
> >> +#define HSR_LIFE_CHECK_INTERVAL		 2000 /* ms */
> >> +#define HSR_NODE_FORGET_TIME		60000 /* ms */
> >> +#define HSR_ANNOUNCE_INTERVAL		  100 /* ms */
> > 
> > Odd alignment
> 
> Only because of the plus chars added by diff. :)

Not really.
#defines don't generally try to right align numbers.
It's up to you though.

> >> diff --git a/net/hsr/hsr_netlink.c b/net/hsr/hsr_netlink.c
> > []
> >> +static const struct nla_policy hsr_genl_policy[HSR_A_MAX + 1] = {
> >> +	[HSR_A_NODE_ADDR] = { .type = NLA_BINARY, .len = ETH_ALEN },
> >> +	[HSR_A_NODE_ADDR_B] = { .type = NLA_BINARY, .len = ETH_ALEN },
> >> +	[HSR_A_IFINDEX] = { .type = NLA_U32 },
> >> +	[HSR_A_IF1_AGE] = { .type = NLA_U32 }, /* Actually signed 32-bit */
> >> +	[HSR_A_IF2_AGE] = { .type = NLA_U32 }, /* Actually signed 32-bit */
> > 
> > Why not use NLA_S32?
> 
> We need the code to work on older kernels as well, where NLA_S32 does not exist.

Not if it's newly going into 3.11 and higher.

> Actually,
> these values never become negative with the current code. During development we returned a
> negative value to mean "out of range" but we have switched to INT_MAX instead. So perhaps
> it's best just to remove these comments?

Probably.  I thought it was unusual.

cheers, Joe
