From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH net-next 0/2] net: bridge: allow user-space to add ext
 learned entries
Date: Thu, 23 Mar 2017 22:00:03 +0200
Message-ID: <20170323200002.GC25688@splinter.mtl.com>
References: <1490264833-28867-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, idosch@mellanox.com, jiri@resnulli.us,
        stephen@networkplumber.org, bridge@lists.linux-foundation.org,
        roopa@cumulusnetworks.com, davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:36578 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932136AbdCWUAG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 16:00:06 -0400
Content-Disposition: inline
In-Reply-To: <1490264833-28867-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 23, 2017 at 12:27:11PM +0200, Nikolay Aleksandrov wrote:
> Hi,
> This set adds the ability to add externally learned entries from
> user-space. For symmetry and proper function we need to allow SW entries
> to take over HW learned ones (similar to how HW can take over SW entries
> currently) which is needed for our use case (evpn) where we have pure SW
> ports and HW ports mixed in a single bridge. This does not play well with
> switchdev devices currently because there's no feedback when the entry is
> taken over, but this case has never worked anyway and feedback can be
> easily added when needed.

Yea, correct. I think we should handle FDB offload in a similar fashion
to route offload. FDBs aren't only of interest to the port to which they
point, but also to the other ports in the bridge. In your example use
case we would actually need to forward to the CPU packets that hit FDB
entries pointing to the SW ports. What would currently happen is that we
would simply flood such packets via the HW ports.
