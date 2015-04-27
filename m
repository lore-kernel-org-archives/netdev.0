From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 -next v2] tc: built-in eBPF exec proxy
Date: Mon, 27 Apr 2015 16:41:44 -0700
Message-ID: <20150427164144.2d7279ef@urahara>
References: <d41d6003521cbb231112e4a78c10cb8c07f05cc2.1429211530.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, ast@plumgrid.com,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36573 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753197AbbD0Xlk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 19:41:40 -0400
Received: by pabsx10 with SMTP id sx10so145231289pab.3
        for <netdev@vger.kernel.org>; Mon, 27 Apr 2015 16:41:39 -0700 (PDT)
In-Reply-To: <d41d6003521cbb231112e4a78c10cb8c07f05cc2.1429211530.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 Apr 2015 21:20:06 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> This work follows upon commit 6256f8c9e45f ("tc, bpf: finalize eBPF
> support for cls and act front-end") and takes up the idea proposed by
> Hannes Frederic Sowa to spawn a shell (or any other command) that holds
> generated eBPF map file descriptors.
> 
> File descriptors, based on their id, are being fetched from the same
> unix domain socket as demonstrated in the bpf_agent, the shell spawned
> via execvpe(2) and the map fds passed over the environment, and thus
> are made available to applications in the fashion of std{in,out,err}
> for read/write access, for example in case of iproute2's examples/bpf/:
> 
>   # env | grep BPF
>   BPF_NUM_MAPS=3
>   BPF_MAP1=6        <- BPF_MAP_ID_QUEUE (id 1)
>   BPF_MAP0=5        <- BPF_MAP_ID_PROTO (id 0)
>   BPF_MAP2=7        <- BPF_MAP_ID_DROPS (id 2)
> 
>   # ls -la /proc/self/fd
>   [...]
>   lrwx------. 1 root root 64 Apr 14 16:46 0 -> /dev/pts/4
>   lrwx------. 1 root root 64 Apr 14 16:46 1 -> /dev/pts/4
>   lrwx------. 1 root root 64 Apr 14 16:46 2 -> /dev/pts/4
>   [...]
>   lrwx------. 1 root root 64 Apr 14 16:46 5 -> anon_inode:bpf-map
>   lrwx------. 1 root root 64 Apr 14 16:46 6 -> anon_inode:bpf-map
>   lrwx------. 1 root root 64 Apr 14 16:46 7 -> anon_inode:bpf-map
> 
> The advantage (as opposed to the direct/native usage) is that now the
> shell is map fd owner and applications can terminate and easily reattach
> to descriptors w/o any kernel changes. Moreover, multiple applications
> can easily read/write eBPF maps simultaneously.
> 
> To further allow users for experimenting with that, next step is to add
> a small helper that can get along with simple data types, so that also
> shell scripts can make use of bpf syscall, f.e to read/write into maps.
> 
> Generally, this allows for prepopulating maps, or any runtime altering
> which could influence eBPF program behaviour (f.e. different run-time
> classifications, skb modifications, ...), dumping of statistics, etc.
> 
> Reference: http://thread.gmane.org/gmane.linux.network/357471/focus=357860
> Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Acked-by: Alexei Starovoitov <ast@plumgrid.com>

Cool but a little hard to explain and awkward to use.
I see no reason not to put it in, might be useful and doesn't interfere
with basic usage.

This will go in for 4.1 version of iproute2.
