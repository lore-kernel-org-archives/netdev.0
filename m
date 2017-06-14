From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/3] ipmr/ip6mr: add Netlink notifications on
 cache reports
Date: Wed, 14 Jun 2017 15:04:10 +0300
Message-ID: <891d876f-18fb-706b-c269-ec8892d2f6ff@cumulusnetworks.com>
References: <20170613170822.16310-1-julien@arista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
        Donald Sharp <sharpd@cumulusnetworks.com>
To: Julien Gomes <julien@arista.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f173.google.com ([209.85.128.173]:35264 "EHLO
        mail-wr0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751624AbdFNMEN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 08:04:13 -0400
Received: by mail-wr0-f173.google.com with SMTP id q97so186718476wrb.2
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 05:04:13 -0700 (PDT)
In-Reply-To: <20170613170822.16310-1-julien@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/06/17 20:08, Julien Gomes wrote:
> Currently, all ipmr/ip6mr cache reports are sent through the
> mroute/mroute6 socket only.
> This forces the use of a single socket for mroute programming, cache
> reports and, regarding ipmr, IGMP messages without Router Alert option
> reception.
> 
> The present patches are aiming to send Netlink notifications in addition
> to the existing igmpmsg/mrt6msg to give user programs a way to handle
> cache reports in parallel with multiple sockets other than the
> mroute/mroute6 socket.
> 
> Julien Gomes (3):
>   rtnetlink: add NEWCACHEREPORT message type
>   ipmr: add netlink notifications on igmpmsg cache reports
>   ip6mr: add netlink notifications on mrt6msg cache reports
> 
>  include/uapi/linux/mroute.h    | 11 ++++++++
>  include/uapi/linux/mroute6.h   | 11 ++++++++
>  include/uapi/linux/rtnetlink.h |  3 ++
>  net/ipv4/ipmr.c                | 63 ++++++++++++++++++++++++++++++++++++++++--
>  net/ipv6/ip6mr.c               | 63 ++++++++++++++++++++++++++++++++++++++++--
>  security/selinux/nlmsgtab.c    |  3 +-
>  6 files changed, 149 insertions(+), 5 deletions(-)
> 

Hi Julien,
This has been on our todo list and I'm definitely interested in the implementation.
A few things that need careful consideration from my POV. First are the security
implications - this sends rtnl multicast messages but the rtnl socket has
the NL_CFG_F_NONROOT_RECV flag thus allowing any user on the system to listen in.
This would allow them to see the full packets and all reports (granted they can see
the notifications even now), but the full packet is like giving them the opportunity
to tcpdump the PIM traffic.
My second (more fixable and minor) concern is about the packet itself, how do you
know that the packet is all linear so you can directly copy it ?

Thanks,
 Nik
