From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v5 4/4] tg3: Fix tx_pending checks for tg3_tso_bug
Date: Mon, 01 Sep 2014 21:23:28 -0700 (PDT)
Message-ID: <20140901.212328.1826121359590626658.davem@davemloft.net>
References: <1409345191-8819-1-git-send-email-bpoirier@suse.de>
	<1409345191-8819-4-git-send-email-bpoirier@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: prashant@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: bpoirier@suse.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1409345191-8819-4-git-send-email-bpoirier@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Poirier <bpoirier@suse.de>
Date: Fri, 29 Aug 2014 13:46:31 -0700

> This puts us in the exceptional situation that a single skb that
> triggers tg3_tso_bug() may require the entire tx ring.

This is really silly.

If you get fed crap, linearize the SKB, end of story.

Don't try to be clever, and absolutely do not adjust gso_max_segs on
the fly as it was never ever designed to change dynamically and
asynchronously to the code paths which use it to size outgoing TCP
segments.

Nothing else needs adjusting, just linearize when you run into a
packet that can't fit into the TX ring because of these weird
restrictions.
