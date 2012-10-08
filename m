From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] vlan: don't deliver frames for unknown vlans to
 protocols
Date: Mon, 08 Oct 2012 14:42:30 -0400 (EDT)
Message-ID: <20121008.144230.1404596032615788891.davem@davemloft.net>
References: <20121008015158.GE25895@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jpirko@redhat.com
To: florz@florz.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121008015158.GE25895@florz.florz.dyndns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Zumbiehl <florz@florz.de>
Date: Mon, 8 Oct 2012 03:51:58 +0200

> This version completely avoids any new state that could need to be spilled
> to RAM, and instead re-checks existence and non-zeroness of the tag. What
> do you think?

At a high level it looks fine and doesn't have the problems mentioned
earlier.

But I wonder if it breaks things, since you do the assignment so late
we no longer handle the case where the VLAN device's MAC address
matches the packet MAC address and the top-level device's does not.

That's handled by logic in vlan_do_receive() which checks for
PACKET_OTHERHOST.

But you're going to unconditionally set PACKET_OTHERHOST, overriding
any decision that code makes.

This turns out to be a really non-trivial area and it's going to take
some time to get this right and audit the change appropriately.
