From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/5] Add bpf support to set sk_bound_dev_if
Date: Mon, 31 Oct 2016 13:01:04 -0400 (EDT)
Message-ID: <20161031.130104.2206412054220058623.davem@davemloft.net>
References: <1477529922-4806-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com,
        daniel@iogearbox.net, maheshb@google.com, tgraf@suug.ch
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51384 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S944774AbcJaRBJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 13:01:09 -0400
In-Reply-To: <1477529922-4806-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed, 26 Oct 2016 17:58:37 -0700

> The recently added VRF support in Linux leverages the bind-to-device
> API for programs to specify an L3 domain for a socket. While
> SO_BINDTODEVICE has been around for ages, not every ipv4/ipv6 capable
> program has support for it. Even for those programs that do support it,
> the API requires processes to be started as root (CAP_NET_RAW) which
> is not desirable from a general security perspective.
> 
> This patch set leverages Daniel Mack's work to attach bpf programs to
> a cgroup:
> 
>     https://www.mail-archive.com/netdev@vger.kernel.org/msg134028.html
> 
> to provide a capability to set sk_bound_dev_if for all AF_INET{6}
> sockets opened by a process in a cgroup when the sockets are allocated.
> 
> This capability enables running any program in a VRF context and is key
> to deploying Management VRF, a fundamental configuration for networking
> gear, with any Linux OS installation.

Ok, after some review I think I understand what's going on here.

It would initially seem simpler to just support forced sk_bound_dev_if
in cgroups.  But I think I understand why you may have gone this way:

1) The cgroup-bpf code always has the cgroup hierarchy propagation
   logic.

2) The may be use cases for doing things with other sock members.

With respect to #2, do you know of any such planned use cases already?

Also, any reason why you don't allow the cgroup bpf sk filter to return
an error code so that the sock creation could be cancelled if the eBPF
program desires that?  It could be useful, I suppose.

Thanks.
