From: Parav Pandit <pandit.parav@gmail.com>
Subject: Re: [PATCH 0/5] Networking cgroup controller
Date: Tue, 23 Aug 2016 14:19:31 +0530
Message-ID: <CAG53R5UY7TH3XiOHa1sEa-zGXKfLm9UYBPR6zwP1KHbDSZe4tg@mail.gmail.com>
References: <1470876798-4024-1-git-send-email-anaravaram@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jonathan Corbet <corbet@lwn.net>, Tejun Heo <tj@kernel.org>,
        lizefan@huawei.com, Johannes Weiner <hannes@cmpxchg.org>,
        davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net,
        linux-doc@vger.kernel.org, cgroups@vger.kernel.org,
        netdev@vger.kernel.org, edumazet@google.com, maheshb@google.com,
        weiwan@google.com, tom@herbertland.com
To: Anoop Naravaram <anaravaram@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:33116 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933335AbcHWJDT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 05:03:19 -0400
In-Reply-To: <1470876798-4024-1-git-send-email-anaravaram@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Anoop,

Regardless of usecase, I think this functionality is best handled as
LSM functionality instead of cgroup.

Tasks which are proposed in this patch are related to access control checks.
LSM already has required hooks for socket operations such as bind(),
listen() as few small examples.

Refer to security_socket_listen() which invokes LSM specific hooks.
This is invoked in source/net/socket.c as part of listen() system call.
LSM hook callback can check whether a given a process can listen to
requested UDP port or not.

Parav


On Thu, Aug 11, 2016 at 6:23 AM, Anoop Naravaram <anaravaram@google.com> wrote:
> This patchset introduces a cgroup controller for the networking subsystem as a
> whole. As of now, this controller will be used for:
>
> * Limiting the specific ports that a process in a cgroup is allowed to bind
>   to or listen on. For example, you can say that all the processes in a
>   cgroup can only bind to ports 1000-2000, and listen on ports 1000-1100, which
>   guarantees that the remaining ports will be available for other processes.
>
> * Restricting which DSCP values processes can use with their sockets. For
>   example, you can say that all the processes in a cgroup can only send
>   packets with a DSCP tag between 48 and 63 (corresponding to TOS values of
>   192 to 255).
>
> * Limiting the total number of udp ports that can be used by a process in a
>   cgroup. For example, you can say that all the processes in one cgroup are
>   allowed to use a total of up to 100 udp ports. Since the total number of udp
>   ports that can be used by all processes is limited, this is useful for
>   rationing out the ports to different process groups.
>
> In the future, more networking-related properties may be added to this
> controller.
>
> Anoop Naravaram (5):
>   net: create the networking cgroup controller
>   net: add bind/listen ranges to net cgroup
>   net: add udp limit to net cgroup
>   net: add dscp ranges to net cgroup
>   net: add test for net cgroup
>
>  Documentation/cgroup-v1/net.txt   |  95 +++++
>  include/linux/cgroup_subsys.h     |   4 +
>  include/net/net_cgroup.h          | 103 ++++++
>  net/Kconfig                       |  10 +
>  net/core/Makefile                 |   1 +
>  net/core/net_cgroup.c             | 706 ++++++++++++++++++++++++++++++++++++++
>  net/ipv4/af_inet.c                |   8 +
>  net/ipv4/inet_connection_sock.c   |   7 +
>  net/ipv4/ip_sockglue.c            |  13 +
>  net/ipv4/udp.c                    |   8 +
>  net/ipv6/af_inet6.c               |   7 +
>  net/ipv6/datagram.c               |   9 +
>  net/ipv6/ipv6_sockglue.c          |   8 +
>  scripts/cgroup/net_cgroup_test.py | 359 +++++++++++++++++++
>  14 files changed, 1338 insertions(+)
>  create mode 100644 Documentation/cgroup-v1/net.txt
>  create mode 100644 include/net/net_cgroup.h
>  create mode 100644 net/core/net_cgroup.c
>  create mode 100755 scripts/cgroup/net_cgroup_test.py
>
> --
> 2.8.0.rc3.226.g39d4020
>
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
