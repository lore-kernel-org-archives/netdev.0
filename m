From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH 2/4] samples/bpf: make bpf_load.c code
 compatible with ELF maps section changes
Date: Tue, 2 May 2017 17:54:51 -0700
Message-ID: <20170503005449.urnux43sril3ganq@ast-mbp>
References: <149372826543.22268.3617359219409721129.stgit@firesoul>
 <149372831600.22268.4042215094788332751.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kafai@fb.com, netdev@vger.kernel.org, eric@regit.org,
        Daniel Borkmann <borkmann@iogearbox.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35835 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750950AbdECAyy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 20:54:54 -0400
Received: by mail-pf0-f195.google.com with SMTP id o68so1704930pfj.2
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 17:54:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <149372831600.22268.4042215094788332751.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 02, 2017 at 02:31:56PM +0200, Jesper Dangaard Brouer wrote:
> This patch does proper parsing of the ELF "maps" section, in-order to
> be both backwards and forwards compatible with changes to the map
> definition struct bpf_map_def, which gets compiled into the ELF file.
> 
> The assumption is that new features with value zero, means that they
> are not in-use.  For backward compatibility where loading an ELF file
> with a smaller struct bpf_map_def, only copy objects ELF size, leaving
> rest of loaders struct zero.  For forward compatibility where ELF file
> have a larger struct bpf_map_def, only copy loaders own struct size
> and verify that rest of the larger struct is zero, assuming this means
> the newer feature was not activated, thus it should be safe for this
> older loader to load this newer ELF file.
> 
> Fixes: fb30d4b71214 ("bpf: Add tests for map-in-map")
> Fixes: 409526bea3c3 ("samples/bpf: bpf_load.c detect and abort if ELF maps section size is wrong")
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

I would just merge patches 2 and 3 to reduce churn,
but it looks like great improvement already.
Acked-by: Alexei Starovoitov <ast@kernel.org>
