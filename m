From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 2/4] samples/bpf: make bpf_load.c code
 compatible with ELF maps section changes
Date: Wed, 3 May 2017 07:48:20 +0200
Message-ID: <20170503074820.23c79a62@redhat.com>
References: <149372826543.22268.3617359219409721129.stgit@firesoul>
        <149372831600.22268.4042215094788332751.stgit@firesoul>
        <20170503005449.urnux43sril3ganq@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kafai@fb.com, netdev@vger.kernel.org, eric@regit.org,
        Daniel Borkmann <borkmann@iogearbox.net>, brouer@redhat.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60484 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750966AbdECFs0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 3 May 2017 01:48:26 -0400
In-Reply-To: <20170503005449.urnux43sril3ganq@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2 May 2017 17:54:51 -0700
Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

> On Tue, May 02, 2017 at 02:31:56PM +0200, Jesper Dangaard Brouer wrote:
> > This patch does proper parsing of the ELF "maps" section, in-order to
> > be both backwards and forwards compatible with changes to the map
> > definition struct bpf_map_def, which gets compiled into the ELF file.
> > 
> > The assumption is that new features with value zero, means that they
> > are not in-use.  For backward compatibility where loading an ELF file
> > with a smaller struct bpf_map_def, only copy objects ELF size, leaving
> > rest of loaders struct zero.  For forward compatibility where ELF file
> > have a larger struct bpf_map_def, only copy loaders own struct size
> > and verify that rest of the larger struct is zero, assuming this means
> > the newer feature was not activated, thus it should be safe for this
> > older loader to load this newer ELF file.
> > 
> > Fixes: fb30d4b71214 ("bpf: Add tests for map-in-map")
> > Fixes: 409526bea3c3 ("samples/bpf: bpf_load.c detect and abort if ELF maps section size is wrong")
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>  
> 
> I would just merge patches 2 and 3 to reduce churn,
> but it looks like great improvement already.

I could have combined them, but I prefer keeping them separate to keep
the ELF changes separated from changing a sample program e.g.
map_perf_test_user.c.  IHMO is is cleaner this way.

> Acked-by: Alexei Starovoitov <ast@kernel.org>
 
Thanks

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
