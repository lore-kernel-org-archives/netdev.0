From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] net: enable interface alias removal via rtnl
Date: Mon, 16 Oct 2017 20:52:57 +0100 (WEST)
Message-ID: <20171016.205257.457189372417045427.davem@davemloft.net>
References: <66bbef72-90fb-7142-2070-07dc0c2b0ca9@gmail.com>
        <20171011142448.31707-1-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsahern@gmail.com, netdev@vger.kernel.org, oliver@hartkopp.net,
        stephen@networkplumber.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34256 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932311AbdJPTxA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 15:53:00 -0400
In-Reply-To: <20171011142448.31707-1-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed, 11 Oct 2017 16:24:48 +0200

> IFLA_IFALIAS is defined as NLA_STRING. It means that the minimal length of
> the attribute is 1 ("\0"). However, to remove an alias, the attribute
> length must be 0 (see dev_set_alias()).
> 
> Let's define the type to NLA_BINARY to allow 0-length string, so that the
> alias can be removed.
> 
> Example:
> $ ip l s dummy0 alias foo
> $ ip l l dev dummy0
> 5: dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
>     link/ether ae:20:30:4f:a7:f3 brd ff:ff:ff:ff:ff:ff
>     alias foo
> 
> Before the patch:
> $ ip l s dummy0 alias ""
> RTNETLINK answers: Numerical result out of range
> 
> After the patch:
> $ ip l s dummy0 alias ""
> $ ip l l dev dummy0
> 5: dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
>     link/ether ae:20:30:4f:a7:f3 brd ff:ff:ff:ff:ff:ff
> 
> CC: Oliver Hartkopp <oliver@hartkopp.net>
> CC: Stephen Hemminger <stephen@networkplumber.org>
> Fixes: 96ca4a2cc145 ("net: remove ifalias on empty given alias")
> Reported-by: Julien FLoret <julien.floret@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied, thank you.
