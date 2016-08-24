From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 0/5] Networking cgroup controller
Date: Wed, 24 Aug 2016 17:03:57 -0400
Message-ID: <20160824210357.GU8185@htj.duckdns.org>
References: <1470876798-4024-1-git-send-email-anaravaram@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: corbet@lwn.net, lizefan@huawei.com, hannes@cmpxchg.org,
        davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net,
        linux-doc@vger.kernel.org, cgroups@vger.kernel.org,
        netdev@vger.kernel.org, edumazet@google.com, maheshb@google.com,
        weiwan@google.com, tom@herbertland.com
To: Anoop Naravaram <anaravaram@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f196.google.com ([209.85.213.196]:35027 "EHLO
        mail-yb0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751799AbcHXVHT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 17:07:19 -0400
Content-Disposition: inline
In-Reply-To: <1470876798-4024-1-git-send-email-anaravaram@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Anoop.

On Wed, Aug 10, 2016 at 05:53:13PM -0700, Anoop Naravaram wrote:
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

Thanks for working on this; however, I share the sentiment expressed
by others that this looks like too piecemeal an approach.  If there
are no alternatives, we surely should consider this but it at least
*looks* like bpf should be able to cover the same functionalities
without having to revise and extend in-kernel capabilities constantly.

Thanks.

-- 
tejun
