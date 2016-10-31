From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] ipv4: fib: Replay events when registering
 FIB notifier
Date: Mon, 31 Oct 2016 14:24:06 -0700
Message-ID: <1477949046.7065.320.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1477948427-9189-1-git-send-email-idosch@idosch.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jiri@mellanox.com,
        mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, Ido Schimmel <idosch@mellanox.com>
To: idosch@idosch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35703 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S947017AbcJaVYJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 17:24:09 -0400
Received: by mail-pf0-f196.google.com with SMTP id s8so9653121pfj.2
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 14:24:08 -0700 (PDT)
In-Reply-To: <1477948427-9189-1-git-send-email-idosch@idosch.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-10-31 at 23:13 +0200, idosch@idosch.org wrote:
> From: Ido Schimmel <idosch@mellanox.com>
> 
> When registering a FIB notifier block we should notify the caller of
> already existing FIB entries and rules, as it would otherwise have an
> incomplete view of the FIB tables. This is especially important for
> switchdev drivers that support FIB offloads. Failing to notify them of
> existing entries may lead to packet loss.
> 
> Upon registration, walk the leafs of all the routing tables and for each
> leaf send notification of existing FIB aliases. Similarly, when
> unregistering the notifier synthesize a deletion event, thereby
> relieving potential callers from the need to perform cleanup.
> 
> The above is consistent with the netdevice notification chain, where
> "registration and up events are replayed to the new notifier" upon
> registration.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Reviewed-by: Jiri Pirko <jiri@mellanox.com>



How well will this work for large FIB tables ?

Holding rtnl while sending thousands of skb will prevent consumers to
make progress ?
