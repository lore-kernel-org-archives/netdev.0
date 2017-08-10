From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next 3/6] rtnetlink: switch
 rtnl_link_get_slave_info_data_size to rcu
Date: Thu, 10 Aug 2017 10:17:07 -0600
Message-ID: <66b0f2eb-1b32-f7f5-046d-93c4febd1a41@gmail.com>
References: <20170810145302.30391-1-fw@strlen.de>
 <20170810145302.30391-4-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:38887 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753039AbdHJQRK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 12:17:10 -0400
Received: by mail-pf0-f193.google.com with SMTP id h75so1064313pfh.5
        for <netdev@vger.kernel.org>; Thu, 10 Aug 2017 09:17:09 -0700 (PDT)
In-Reply-To: <20170810145302.30391-4-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/10/17 8:52 AM, Florian Westphal wrote:
> David Ahern reports following splat:
>  RTNL: assertion failed at net/core/dev.c (5717)
>  netdev_master_upper_dev_get+0x5f/0x70
>  if_nlmsg_size+0x158/0x240
>  rtnl_calcit.isra.26+0xa3/0xf0
> 
> rtnl_link_get_slave_info_data_size currently assumes RTNL protection, but
> there appears to be no hard requirement for this, so use rcu instead.
> 
> At the time of this writing, there are three 'get_slave_size' callbacks
> (now invoked under rcu): bond_get_slave_size, vrf_get_slave_size and
> br_port_get_slave_size, all return constant only (i.e. they don't sleep).
> 
> Fixes: 6853dd488119 ("rtnetlink: protect handler table with rcu")
> Reported-by: David Ahern <dsahern@gmail.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  net/core/rtnetlink.c | 16 ++++++++++++----
>  1 file changed, 12 insertions(+), 4 deletions(-)

Acked-by: David Ahern <dsahern@gmail.com>
