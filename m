From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next 6/8] ipv4: fib: Add an API to request a FIB dump
Date: Wed, 16 Nov 2016 15:51:01 +0100
Message-ID: <e795e6e0-a680-a2c3-7d5e-afd966104a4a@stressinduktion.org>
References: <1479305343-13167-1-git-send-email-jiri@resnulli.us>
 <1479305343-13167-7-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:56042 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752834AbcKPOvG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 09:51:06 -0500
In-Reply-To: <1479305343-13167-7-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16.11.2016 15:09, Jiri Pirko wrote:
> From: Ido Schimmel <idosch@mellanox.com>
> 
> Commit b90eb7549499 ("fib: introduce FIB notification infrastructure")
> introduced a new notification chain to notify listeners (f.e., switchdev
> drivers) about addition and deletion of routes.
> 
> However, upon registration to the chain the FIB tables can already be
> populated, which means potential listeners will have an incomplete view
> of the tables.
> 
> Solve that by adding an API to request a FIB dump. The dump itself it
> done using RCU in order not to starve consumers that need RTNL to make
> progress.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Have you looked at potential inconsistencies resulting of RCU walking
the table and having concurrent inserts?

I don't see a way around doing a journal like in filesystems somehow,
but maybe the effects are not that severe and it is not a problem after all.

Bye,
Hannes
