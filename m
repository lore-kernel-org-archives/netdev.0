From: Neil Horman <nhorman@tuxdriver.com>
Subject: [RFC PATCH 0/2 v2] net: alternate proposal for using macvlans with forwarding acceleration
Date: Fri,  4 Oct 2013 16:10:03 -0400
Message-ID: <1380917405-23801-1-git-send-email-nhorman@tuxdriver.com>
References: <1380140209-24587-1-git-send-email-nhorman@tuxdriver.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52903 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751174Ab3JDUKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 16:10:24 -0400
In-Reply-To: <1380140209-24587-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey all-
     heres the next, updated version of the vsi/macvlan integration that we've
been discussing.

Some change notes:

* Changes to the fowarding ops structure - Removed the priv_size field, and
added a flags field.  Removal of the priv_size field was accomplished by just
having the add method return a void * and using ERR_PTR and PTR_ERR checks,
which also allows us to allocate memory for the acceleration path in the driver,
which I like.  I'm not super happy still with how I'm using the flags (currenly
only used to indicate support for feature sets), but at least we have the flags
now, and they can be exposed to user space via iproute2 or ethtool if need be

* Changes to the Transmit path - Specifically I'm using dev_queue_xmit to send
frames now, which I like as it makes the macvlan subject to the lowerdevs qdisc
configuration.

* Changes to the acceleration fail path behavior - Now if we don't/can't use
acceleration, we just fall back to using the normal macvlan software switch
strategy

* General clenups (some renaming, that I'm not super sure of, but I though
forwarding acceleration (fwd) would be a better prefix than l2 acceleration).

Still a long way to go I think, and lots of tweaking to do, but I didn't want to
keep you waiting John.  Anywho, take a look at what I'm doing and feel free to
rip it apart.

Thanks!
Neil
