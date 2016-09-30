From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH] net: rtnl: avoid uninitialized data in IFLA_VF_VLAN_LIST handling
Date: Fri, 30 Sep 2016 23:12:40 +0300
Message-ID: <CAJ3xEMih26x2BFgokoapX6_gXSAh+wwRNS1i-vjsBifthiM20A@mail.gmail.com>
References: <20160930161416.18660-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Eric Dumazet <edumazet@google.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Nogah Frankel <nogahf@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>, Moshe Shemesh <moshe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:36523 "EHLO
        mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750703AbcI3UMm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 16:12:42 -0400
In-Reply-To: <20160930161416.18660-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 30, 2016 at 7:13 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> With the newly added support for IFLA_VF_VLAN_LIST netlink messages,
> we get a warning about potential uninitialized variable use in
> the parsing of the user input when enabling the -Wmaybe-uninitialized
> warning:
>
> net/core/rtnetlink.c: In function 'do_setvfinfo':
> net/core/rtnetlink.c:1756:9: error: 'ivvl$' may be used uninitialized in this function [-Werror=maybe-uninitialized]
>
> I have not been able to prove whether it is possible to arrive in
> this code with an empty IFLA_VF_VLAN_LIST block, but if we do,
> then ndo_set_vf_vlan gets called with uninitialized arguments.
>
> This adds an explicit check for an empty list, making it obvious
> to the reader and the compiler that this cannot happen.
>
> Fixes: 79aab093a0b5 ("net: Update API for VF vlan protocol 802.1ad support")
Added the authors of the above patch

> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
