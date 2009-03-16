From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: [patch 0/6] netfilter: ctnetlink allocation improvement
Date: Mon, 16 Mar 2009 23:06:59 +0100
Message-ID: <20090316220659.756862181@jonathan.eitzenberger.org>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

what follows is a small patchset against net-next-2.6 which tries to
improve the way ctnetlink events are allocated.  By allocating the
ctnetlink skbs roughly the size of the message we prevent the skb from
later being reallocated in netlink_trim().

Though I haven't got any hard performance numbers yet I think this
might introduce a noticable performance gain.

The overall idea of these patches is to compute the proto independant
attribute sizes at compile time, the proto-dependant parts are
computed at registration of the actual proto helpers.  This is
achieved by introducing nla_policy_len(), which computes the max.
length of a nla_policy.

I also have to introduce NF_CT_HELPER_NAME_LEN as an upper limit for
the conntrack protcol helper names, which is not much of a problem
because all names in mainline are actually shorter than that.

It would be great to have that being merged.  Please share youre
comments.

Thanks.

  /holger

