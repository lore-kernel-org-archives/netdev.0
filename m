From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: breakage due to commit 6e617de84e ("net: avoid a full fib
 lookup when rp_filter is disabled")
Date: Fri, 27 Oct 2017 14:46:27 +0200
Message-ID: <1509108387.2460.31.camel@redhat.com>
References: <248fe046-1f13-1a9e-b587-e16515395be5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: David Ahern <dsahern@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42160 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752258AbdJ0Mq3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 27 Oct 2017 08:46:29 -0400
In-Reply-To: <248fe046-1f13-1a9e-b587-e16515395be5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-10-26 at 21:50 -0600, David Ahern wrote:
> Your commit:
> 
> commit 6e617de84e87d626d1e976fc30e1322239fd4d2d
> Author: Paolo Abeni <pabeni@redhat.com>
> Date:   Wed Sep 20 18:26:53 2017 +0200
> 
>     net: avoid a full fib lookup when rp_filter is disabled.
> 
> breaks a test case that uses a veth pair in the same network namespace
> but separate VRFs. This setup:
> 
> vrf add vrf0 table 1001
> vrf add vrf1 table 1002
> 
> ip link add virt01 type veth peer name virt10
> ip link set virt01 master vrf0
> ip link set virt10 master vrf1
> 
> ip addr add 172.16.20.20/24 dev virt01
> ip link set virt01 up
> 
> ip addr add 172.16.20.21/24 dev virt10
> ip link set virt10 up
> 
> ping -c 1 -I vrf0 172.16.20.21
> 
> fails due to:
> 
>     if (inet_lookup_ifaddr_rcu(net, src))
>        return -EINVAL;
> 
> in fib_validate_source.

Thank you for the report.

Please give me a little time to investigate the issue; unfortunately I
would not be able to work on this untill Monday.

Cheers,

Paolo
