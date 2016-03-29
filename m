From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net] bpf: make padding in bpf_tunnel_key explicit
Date: Tue, 29 Mar 2016 15:06:16 -0700
Message-ID: <20160329220614.GA20258@ast-mbp.thefacebook.com>
References: <6589c70157238797e63986eeea67cfe2abfb3260.1459288316.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36439 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752134AbcC2WGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 18:06:20 -0400
Received: by mail-pf0-f181.google.com with SMTP id e128so3860237pfe.3
        for <netdev@vger.kernel.org>; Tue, 29 Mar 2016 15:06:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <6589c70157238797e63986eeea67cfe2abfb3260.1459288316.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 30, 2016 at 12:02:00AM +0200, Daniel Borkmann wrote:
> Make the 2 byte padding in struct bpf_tunnel_key between tunnel_ttl
> and tunnel_label members explicit. No issue has been observed, and
> gcc/llvm does padding for the old struct already, where tunnel_label
> was not yet present, so the current code works, but since it's part
> of uapi, make sure we don't introduce holes in structs.
> 
> Therefore, add tunnel_ext that we can use generically in future
> (f.e. to flag OAM messages for backends, etc). Also add the offset
> to the compat tests to be sure should some compilers not padd the
> tail of the old version of bpf_tunnel_key.
> 
> Fixes: 4018ab1875e0 ("bpf: support flow label for bpf_skb_{set, get}_tunnel_key")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Alexei Starovoitov <ast@kernel.org>
