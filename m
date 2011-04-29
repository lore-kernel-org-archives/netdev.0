From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix incorrect unregistration of sysctl when last
 ip deleted
Date: Fri, 29 Apr 2011 13:45:24 -0700 (PDT)
Message-ID: <20110429.134524.116375005.davem@davemloft.net>
References: <201104272312.p3RNCcl6002068@jgmyers-vm1.eng.proofpoint.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jgmyers@proofpoint.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201104272312.p3RNCcl6002068@jgmyers-vm1.eng.proofpoint.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Myers <jgmyers@proofpoint.com>
Date: Wed, 27 Apr 2011 16:12:38 -0700

> When the last ip address is deleted, the kernel disables IPv6 on the
> interface. (Not sure why, but that's beside the point.) The call that
> does this is over-aggressive--it indicates the interface is about to
> be removed even though that isn't necessarily so.
> 
> This causes IPv6 to, among other things, unregister its sysctl
> parameters for the interface. Thus, the "accept_ra" and "addrconf"
> settings can't be set on the interface until after the interface has
> been brought back up, which is too late.
> 
> Signed-off-by: John Gardiner Myers <jgmyers@proofpoint.com>
> Cc: stable@kernel.org

I'm not applying this, at least without some more discussion.

I can't see what you gain from this change.

First of all, when the machine boots up, you already have the problem
that you cannot set the accept_ra and addrconf sysctl settings before
the first ipv6 address is added to the interface.

So by definition you already cannot make the settings before it is
"too late" and the device is already engaging in ipv6 activity.

Giving you the capability to handle this across full ipv6 address
deletions on the device later on doesn't add anything, and at best it
gives people a false sense of security about being able to preserve
these settings across an ipv6 disable on the device.

If people are going to use this new behavior to do some trick like:

1) Let device come up and assign ipv6 addresses so that sysctls appear
2) Set ipv6 sysctls how actually desired
3) Delete all ipv6 addresses
4) Add them all back

Then I doubly do not want to set a precedent for this kind of usage
by applying this patch.  Fix the real problem.

This behavior has been here, and intentionally so, since Alexey added
the "how" parameter to addrconf_ifdown() back in 1997.

Furthermore, there are other side effects to changing the 'how' parameter
to zero in this case and I haven't seen any analysis that those won't
cause any other undesirable side effects either.

So again, I'm not applying this patch, sorry.
