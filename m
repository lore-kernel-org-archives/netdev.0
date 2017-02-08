From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] lwtunnel: valid encap attr check should return 0
 when lwtunnel is disabled
Date: Wed, 08 Feb 2017 12:55:26 -0500 (EST)
Message-ID: <20170208.125526.1458078959708739209.davem@davemloft.net>
References: <1486574940-6513-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pupilla@libero.it
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55256 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751781AbdBHRz2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 12:55:28 -0500
In-Reply-To: <1486574940-6513-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed,  8 Feb 2017 09:29:00 -0800

> An error was reported upgrading to 4.9.8:
>     root@Typhoon:~# ip route add default table 210 nexthop dev eth0 via 10.68.64.1
>     weight 1 nexthop dev eth0 via 10.68.64.2 weight 1
>     RTNETLINK answers: Operation not supported
> 
> The problem occurs when CONFIG_LWTUNNEL is not enabled and a multipath
> route is submitted.
> 
> The point of lwtunnel_valid_encap_type_attr is catch modules that
> need to be loaded before any references are taken with rntl held. With
> CONFIG_LWTUNNEL disabled, there will be no modules to load so the
> lwtunnel_valid_encap_type_attr stub should just return 0.
> 
> Fixes: 9ed59592e3e3 ("lwtunnel: fix autoload of lwt modules")
> Reported-by: pupilla@libero.it
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied and queued up for -stable, thanks for fixing this so quickly David.
