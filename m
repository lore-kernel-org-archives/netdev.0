From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] samples/bpf: bpf_load.c order of prog_fd[] should
 correspond with ELF order
Date: Wed, 31 May 2017 12:59:39 -0400 (EDT)
Message-ID: <20170531.125939.899346888273269086.davem@davemloft.net>
References: <149614787132.15375.2590780903240304298.stgit@firesoul>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41140 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751118AbdEaQ7l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 12:59:41 -0400
In-Reply-To: <149614787132.15375.2590780903240304298.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 30 May 2017 14:37:51 +0200

> An eBPF ELF file generated with LLVM can contain several program
> section, which can be used for bpf tail calls.  The bpf prog file
> descriptors are accessible via array prog_fd[].
> 
> At-least XDP samples assume ordering, and uses prog_fd[0] is the main
> XDP program to attach.  The actual order of array prog_fd[] depend on
> whether or not a bpf program section is referencing any maps or not.
> Not using a map result in being loaded/processed after all other
> prog section.  Thus, this can lead to some very strange and hard to
> debug situation, as the user can only see a FD and cannot correlated
> that with the ELF section name.
> 
> The fix is rather simple, and even removes duplicate memcmp code.
> Simply load program sections as the last step, instead of
> load_and_attach while processing the relocation section.
> 
> When working with tail calls, it become even more essential that the
> order of prog_fd[] is consistant, like the current dependency of the
> map_fd[] order.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Applied to net-next, thanks Jesper.
