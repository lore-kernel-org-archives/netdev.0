From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [patch net-next 14/17] mlxsw: spectrum_router: Add support for
 IPv6 routes addition / deletion
Date: Wed, 19 Jul 2017 19:43:45 +0300
Message-ID: <20170719164345.GA23668@splinter>
References: <20170719070232.28457-1-jiri@resnulli.us>
 <20170719070232.28457-15-jiri@resnulli.us>
 <983f0254-9539-213d-f140-63b542d8f23e@gmail.com>
 <20170719163052.GB10775@splinter>
 <ca78d11f-bf7d-5fd3-756b-6faedfd86758@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        davem@davemloft.net, mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0047.outbound.protection.outlook.com ([104.47.1.47]:31616
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753709AbdGSQnw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Jul 2017 12:43:52 -0400
Content-Disposition: inline
In-Reply-To: <ca78d11f-bf7d-5fd3-756b-6faedfd86758@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 19, 2017 at 10:36:52AM -0600, David Ahern wrote:
> >> 2. How are routes with devices unrelated to ports owned by this driver
> >> handled?
> > 
> > They are handled just like any other route, but they don't have a valid
> > RIF (for directly connected routes) or an adjacency group (for
> > gatewayed routes), so the check in mlxsw_sp_fib_entry_should_offload()
> > will return false and they will be programmed to the device with trap
> > action, but using a trap ID (RTR_INGRESS0) with a lower traffic class
> > than IP2ME, so packets that actually need to be locally received by the
> > CPU have a better QoS.
> 
> so mlxsw keeps a copy of the complete FIB for IPv4 and IPv6, even routes
> unrelated to its ports?

If we don't reflect all the routes in the system to the ASIC, then we'll
have a broken routing table and a different behavior from what you would
get with plain NICs.
