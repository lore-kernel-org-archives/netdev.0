From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net] samples/bpf: bpf_load.c order of prog_fd[] should
 correspond with ELF order
Date: Tue, 30 May 2017 09:34:12 -0700
Message-ID: <20170530163410.mhag3k5nssohcofd@ast-mbp.dhcp.thefacebook.com>
References: <149614787132.15375.2590780903240304298.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33755 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750950AbdE3QeP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 12:34:15 -0400
Received: by mail-pf0-f193.google.com with SMTP id f27so19066874pfe.0
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 09:34:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <149614787132.15375.2590780903240304298.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 30, 2017 at 02:37:51PM +0200, Jesper Dangaard Brouer wrote:
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

Looks fine, but imo net-next is better, since it's not a bugfix
to anything in the net tree, but a general improvement.

Acked-by: Alexei Starovoitov <ast@kernel.org>
