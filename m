From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v7 net-next 0/6] net: Add bpf support for sockets
Date: Thu, 1 Dec 2016 08:59:39 -0800
Message-ID: <20161201165938.GG46200@ast-mbp.thefacebook.com>
References: <1480610888-31082-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com,
        daniel@iogearbox.net, maheshb@google.com, tgraf@suug.ch
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33037 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933600AbcLAQ7n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 11:59:43 -0500
Received: by mail-pg0-f66.google.com with SMTP id 3so5137703pgd.0
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 08:59:43 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1480610888-31082-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 01, 2016 at 08:48:02AM -0800, David Ahern wrote:
> The recently added VRF support in Linux leverages the bind-to-device
> API for programs to specify an L3 domain for a socket. While
> SO_BINDTODEVICE has been around for ages, not every ipv4/ipv6 capable
> program has support for it. Even for those programs that do support it,
> the API requires processes to be started as root (CAP_NET_RAW) which
> is not desirable from a general security perspective.
> 
> This patch set leverages Daniel Mack's work to attach bpf programs to
> a cgroup to provide a capability to set sk_bound_dev_if for all
> AF_INET{6} sockets opened by a process in a cgroup when the sockets
> are allocated.
> 
> For example:
>  1. configure vrf (e.g., using ifupdown2)
>         auto eth0
>         iface eth0 inet dhcp
>             vrf mgmt
> 
>         auto mgmt
>         iface mgmt
>             vrf-table auto
> 
>  2. configure cgroup
>         mount -t cgroup2 none /tmp/cgroupv2
>         mkdir /tmp/cgroupv2/mgmt
>         test_cgrp2_sock /tmp/cgroupv2/mgmt 15
> 
>  3. set shell into cgroup (e.g., can be done at login using pam)
>         echo $$ >> /tmp/cgroupv2/mgmt/cgroup.procs
> 
> At this point all commands run in the shell (e.g, apt) have sockets
> automatically bound to the VRF (see output of ss -ap 'dev == <vrf>'),
> including processes not running as root.
> 
> This capability enables running any program in a VRF context and is key
> to deploying Management VRF, a fundamental configuration for networking
> gear, with any Linux OS installation.
> 
> This patchset also exports the socket family, type and protocol as
> read-only allowing bpf filters to deny a process in a cgroup the ability
> to open specific types of AF_INET or AF_INET6 sockets.
> 
> v7
> - comments from Alexei

Looks great.
In case you need to change something. Please keep my Acks
on patches that were kept as-is.
Thanks
