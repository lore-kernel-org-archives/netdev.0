From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH V1] samples/bpf: bpf_load.c detect and abort if
 ELF maps section size is wrong
Date: Fri, 28 Apr 2017 20:35:21 -0700
Message-ID: <20170429033519.2iyv7zjm7z43liuw@ast-mbp>
References: <20170428082816.20a34395@redhat.com>
 <149338948065.27354.8568861008673180957.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kafai@fb.com, netdev@vger.kernel.org, eric@regit.org,
        Daniel Borkmann <borkmann@iogearbox.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33885 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1163585AbdD2DfZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 23:35:25 -0400
Received: by mail-pf0-f194.google.com with SMTP id g23so19985093pfj.1
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 20:35:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <149338948065.27354.8568861008673180957.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 28, 2017 at 04:25:04PM +0200, Jesper Dangaard Brouer wrote:
> The struct bpf_map_def was extended in commit fb30d4b71214 ("bpf: Add tests
> for map-in-map") with member unsigned int inner_map_idx.  This changed the size
> of the maps section in the generated ELF _kern.o files.
> 
> Unfortunately the loader in bpf_load.c does not detect or handle this.  Thus,
> older _kern.o files became incompatible, and caused hard-to-debug errors
> where the syscall validation rejected BPF_MAP_CREATE request.
> 
> This patch only detect the situation and aborts load_bpf_file(). It also
> add code comments warning people that read this loader for inspiration
> for these pitfalls.
> 
> Fixes: fb30d4b71214 ("bpf: Add tests for map-in-map")
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Thanks!
Acked-by: Alexei Starovoitov <ast@kernel.org>

> Is it worth to implement proper backward-compat loading of older ELF objects
> with this bpf-loader?

probably yes, since it looks like a bunch of code in samples/bpf/ still
depend on it and some features are missing in tools/lib/bpf,
so unless we actively work on improving libbpf.a 
we won't be able to get rid of this 'sample' loader for some time.
