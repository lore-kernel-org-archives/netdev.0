From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: rtnl: avoid uninitialized data in
 IFLA_VF_VLAN_LIST handling
Date: Mon, 03 Oct 2016 01:32:25 -0400 (EDT)
Message-ID: <20161003.013225.2126712838089878159.davem@davemloft.net>
References: <20160930161416.18660-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, nicolas.dichtel@6wind.com,
        nikolay@cumulusnetworks.com, jiri@mellanox.com,
        edumazet@google.com, bblanco@plumgrid.com,
        hannes@stressinduktion.org, nogahf@mellanox.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160930161416.18660-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 30 Sep 2016 18:13:49 +0200

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
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thanks.
