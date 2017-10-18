From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v6 0/5] bpf: security: New file mode and LSM
 hooks for eBPF object permission control
Date: Wed, 18 Oct 2017 13:47:29 +0100 (WEST)
Message-ID: <20171018.134729.837318478487425125.davem@davemloft.net>
References: <20171016191135.8046-1-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Selinux@tycho.nsa.gov,
        linux-security-module@vger.kernel.org, jeffv@google.com,
        alexei.starovoitov@gmail.com, lorenzo@google.com,
        daniel@iogearbox.net, sds@tycho.nsa.gov, james.l.morris@oracle.com,
        paul@paul-moore.com, fengc@google.com
To: chenbofeng.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60822 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756418AbdJRMrk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 08:47:40 -0400
In-Reply-To: <20171016191135.8046-1-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Date: Mon, 16 Oct 2017 12:11:30 -0700

> Much like files and sockets, eBPF objects are accessed, controlled, and
> shared via a file descriptor (FD). Unlike files and sockets, the
> existing mechanism for eBPF object access control is very limited.
> Currently there are two options for granting accessing to eBPF
> operations: grant access to all processes, or only CAP_SYS_ADMIN
> processes. The CAP_SYS_ADMIN-only mode is not ideal because most users
> do not have this capability and granting a user CAP_SYS_ADMIN grants too
> many other security-sensitive permissions. It also unnecessarily allows
> all CAP_SYS_ADMIN processes access to eBPF functionality. Allowing all
> processes to access to eBPF objects is also undesirable since it has
> potential to allow unprivileged processes to consume kernel memory, and
> opens up attack surface to the kernel.
> 
> Adding LSM hooks maintains the status quo for systems which do not use
> an LSM, preserving compatibility with userspace, while allowing security
> modules to choose how best to handle permissions on eBPF objects. Here
> is a possible use case for the lsm hooks with selinux module:
> 
> The network-control daemon (netd) creates and loads an eBPF object for
> network packet filtering and analysis. It passes the object FD to an
> unprivileged network monitor app (netmonitor), which is not allowed to
> create, modify or load eBPF objects, but is allowed to read the traffic
> stats from the map.
> 
> Selinux could use these hooks to grant the following permissions:
> allow netd self:bpf_map { create read write};
> allow netmonitor netd:fd use;
> allow netmonitor netd:bpf_map read;
> 
> In this patch series, A file mode is added to bpf map to store the
> accessing mode. With this file mode flags, the map can be obtained read
> only, write only or read and write. With the help of this file mode,
> several security hooks can be added to the eBPF syscall implementations
> to do permissions checks. These LSM hooks are mainly focused on checking
> the process privileges before it obtains the fd for a specific bpf
> object. No matter from a file location or from a eBPF id. Besides that,
> a general check hook is also implemented at the start of bpf syscalls so
> that each security module can have their own implementation on the reset
> of bpf object related functionalities.
> 
> In order to store the ownership and security information about eBPF
> maps, a security field pointer is added to the struct bpf_map. And the
> last two patch set are implementation of selinux check on these hooks
> introduced, plus an additional check when eBPF object is passed between
> processes using unix socket as well as binder IPC.

Series applied.
