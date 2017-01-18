From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] lwtunnel: fix autoload of lwt modules
Date: Wed, 18 Jan 2017 17:07:48 -0500 (EST)
Message-ID: <20170118.170748.1892517744246492000.davem@davemloft.net>
References: <1484693856-26021-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rshearma@brocade.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42196 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752697AbdARWIq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 17:08:46 -0500
In-Reply-To: <1484693856-26021-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 17 Jan 2017 14:57:36 -0800

> Trying to add an mpls encap route when the MPLS modules are not loaded
> hangs. For example:
 ...
> The problem is that lwtunnel_build_state is called with rtnl lock
> held preventing mpls_init from registering.
> 
> Given the potential references held by the time lwtunnel_build_state it
> can not drop the rtnl lock to the load module. So, extract the module
> loading code from lwtunnel_build_state into a new function to validate
> the encap type. The new function is called while converting the user
> request into a fib_config which is well before any table, device or
> fib entries are examined.
> 
> Fixes: 745041e2aaf1 ("lwtunnel: autoload of lwt modules")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> v2
> - extract the module load attempt into a separate function that is
>   called early in the newroute code paths

Ok, this looks like it should work.

Assuming it passed my build tests, I'll push this out and queue it for
-stable.

Thanks!
