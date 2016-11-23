From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [patch net-next v2 09/11] ipv4: fib: Add an API to request a FIB
 dump
Date: Wed, 23 Nov 2016 21:53:28 +0200
Message-ID: <20161123195328.aqzbhf263z2pq2e7@splinter>
References: <1479911670-4525-1-git-send-email-jiri@resnulli.us>
 <1479911670-4525-10-git-send-email-jiri@resnulli.us>
 <fa5e105b-9109-1c30-c07c-5a2b0720ffec@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        kaber@trash.net
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:47787 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933854AbcKWUDg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 15:03:36 -0500
Content-Disposition: inline
In-Reply-To: <fa5e105b-9109-1c30-c07c-5a2b0720ffec@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 23, 2016 at 06:47:03PM +0100, Hannes Frederic Sowa wrote:
> Hmm, I think you need to read the sequence counter under rtnl_lock to
> have an ordering with the rest of the updates to the RCU trie. Otherwise
> you don't know if the fib trie has the correct view regarding to the
> incoming notifications as a whole. This is also necessary during restarts.

I spent quite a lot of time thinking about this specific issue, but I
couldn't convince myself that the read should be done under RTNL and I'm
not sure I understand your reasoning. Can you please elaborate?

If, before each notification sent, we call atomic_inc() and then call
atomic_read() at the end, then how can we be tricked?

Thanks for looking into this!
