From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH V1] samples/bpf: bpf_load.c detect and abort if
 ELF maps section size is wrong
Date: Sat, 29 Apr 2017 09:57:08 +0200
Message-ID: <20170429095708.206dc5e7@redhat.com>
References: <20170428082816.20a34395@redhat.com>
        <149338948065.27354.8568861008673180957.stgit@firesoul>
        <20170429033519.2iyv7zjm7z43liuw@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kafai@fb.com, netdev@vger.kernel.org, eric@regit.org,
        Daniel Borkmann <borkmann@iogearbox.net>, brouer@redhat.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43474 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1165231AbdD2H5P (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 29 Apr 2017 03:57:15 -0400
In-Reply-To: <20170429033519.2iyv7zjm7z43liuw@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Apr 2017 20:35:21 -0700
Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

> On Fri, Apr 28, 2017 at 04:25:04PM +0200, Jesper Dangaard Brouer wrote:
> > The struct bpf_map_def was extended in commit fb30d4b71214 ("bpf: Add tests
> > for map-in-map") with member unsigned int inner_map_idx.  This changed the size
> > of the maps section in the generated ELF _kern.o files.
> > 
> > Unfortunately the loader in bpf_load.c does not detect or handle this.  Thus,
> > older _kern.o files became incompatible, and caused hard-to-debug errors
> > where the syscall validation rejected BPF_MAP_CREATE request.
> > 
> > This patch only detect the situation and aborts load_bpf_file(). It also
> > add code comments warning people that read this loader for inspiration
> > for these pitfalls.
> > 
> > Fixes: fb30d4b71214 ("bpf: Add tests for map-in-map")
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>  
> 
> Thanks!
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Thanks!

> > Is it worth to implement proper backward-compat loading of older ELF objects
> > with this bpf-loader?  
> 
> probably yes, since it looks like a bunch of code in samples/bpf/ still
> depend on it and some features are missing in tools/lib/bpf,
> so unless we actively work on improving libbpf.a 
> we won't be able to get rid of this 'sample' loader for some time.

Okay, I'll work on that next week. Hoping I can make the merge window,
so we avoid having a non-backward compat bpf_load in a kernel release.

p.s. I'll be presenting about XDP in Sweden Thur+Friday next week:
 https://lundlinuxcon.org/?page=current

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
