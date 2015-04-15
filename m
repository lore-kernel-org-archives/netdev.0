From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH iproute2 -next] tc: built-in eBPF exec proxy
Date: Wed, 15 Apr 2015 21:24:41 +0200
Message-ID: <1429125881.3784681.254269961.7BFEAE36@webmail.messagingengine.com>
References: <e970d60e68be0ac905542635cc28abb2bf1bebea.1429109269.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:41383 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751607AbbDOTYm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 15:24:42 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 11C3C20DA3
	for <netdev@vger.kernel.org>; Wed, 15 Apr 2015 15:24:42 -0400 (EDT)
In-Reply-To: <e970d60e68be0ac905542635cc28abb2bf1bebea.1429109269.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 15, 2015, at 16:52, Daniel Borkmann wrote:
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
> Reference:
> http://thread.gmane.org/gmane.linux.network/357471/focus=357860
> Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Great worl!

Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
