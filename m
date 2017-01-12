From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] Introduce a sysctl that modifies the value
 of PROT_SOCK.
Date: Thu, 12 Jan 2017 06:39:57 -0800
Message-ID: <1484231997.15816.36.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20161231125505.7f0c7dff@xeon-e3>
         <20170112065225.GB2345@templeofstupid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Krister Johansen <kjlx@templeofstupid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35957 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750720AbdALOj7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 09:39:59 -0500
Received: by mail-pf0-f195.google.com with SMTP id b22so3820701pfd.3
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 06:39:59 -0800 (PST)
In-Reply-To: <20170112065225.GB2345@templeofstupid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-01-11 at 22:52 -0800, Krister Johansen wrote:
> Add net.ipv4.ip_unprotected_port_start, which is a per namespace sysctl
> that denotes the first unprotected inet port in the namespace.  To
> disable all protected ports set this to zero.  It also checks for
> overlap with the local port range.  The protected and local range may
> not overlap.
> 
> The use case for this change is to allow containerized processes to bind
> to priviliged ports, but prevent them from ever being allowed to modify
> their container's network configuration.  The latter is accomplished by
> ensuring that the network namespace is not a child of the user
> namespace.  This modification was needed to allow the container manager
> to disable a namespace's priviliged port restrictions without exposing
> control of the network namespace to processes in the user namespace.
> 
> Signed-off-by: Krister Johansen <kjlx@templeofstupid.com>
> ---
>  include/net/ip.h               | 10 +++++++++
>  include/net/netns/ipv4.h       |  1 +
>  net/ipv4/af_inet.c             |  5 ++++-
>  net/ipv4/sysctl_net_ipv4.c     | 50 +++++++++++++++++++++++++++++++++++++++++-
>  net/ipv6/af_inet6.c            |  3 ++-
>  net/netfilter/ipvs/ip_vs_ctl.c |  7 +++---
>  net/sctp/socket.c              | 10 +++++----
>  security/selinux/hooks.c       |  3 ++-

Adding a new sysctl without documentation is generally not accepted.

Please take a look at Documentation/networking/ip-sysctl.txt

BTW, sticking to 'unprivileged' ports might be better than 'unprotected'
which is vague.


 
