From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net PATCH] bpf: devmap fix arithmetic overflow in bitmap_size
 calculation
Date: Thu, 19 Oct 2017 15:12:46 -0700
Message-ID: <20171019221245.a7grq3csbpixjgpn@ast-mbp>
References: <150842903200.12537.10765604428561566031.stgit@john-XPS-13-9360>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: richard@nod.at, davem@davemloft.net, netdev@vger.kernel.org,
        borkmann@iogearbox.net
To: John Fastabend <john.r.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:47974 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753342AbdJSWMt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 18:12:49 -0400
Received: by mail-pf0-f195.google.com with SMTP id z11so7994246pfk.4
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 15:12:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <150842903200.12537.10765604428561566031.stgit@john-XPS-13-9360>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 19, 2017 at 09:03:52AM -0700, John Fastabend wrote:
> An integer overflow is possible in dev_map_bitmap_size() when
> calculating the BITS_TO_LONG logic which becomes, after macro
> replacement,
> 
> 	(((n) + (d) - 1)/ (d))
> 
> where 'n' is a __u32 and 'd' is (8 * sizeof(long)). To avoid
> overflow cast to u64 before arithmetic.
> 
> Reported-by: Richard Weinberger <richard@nod.at>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: John Fastabend <john.fastabend@gmail.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
