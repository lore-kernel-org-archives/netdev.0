From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] net: filter: make JITs zero A for SKF_AD_ALU_XOR_X
Date: Tue, 5 Jan 2016 09:43:10 -0800
Message-ID: <20160105174309.GA83548@ast-mbp.thefacebook.com>
References: <1452007387-626-1-git-send-email-rabin@rab.in>
 <568BF11F.1060507@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rabin Vincent <rabin@rab.in>, davem@davemloft.net,
	netdev@vger.kernel.org, ast@kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-mips@linux-mips.org,
	linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:32883 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752073AbcAERnP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 12:43:15 -0500
Content-Disposition: inline
In-Reply-To: <568BF11F.1060507@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 05, 2016 at 05:36:47PM +0100, Daniel Borkmann wrote:
> On 01/05/2016 04:23 PM, Rabin Vincent wrote:
> >The SKF_AD_ALU_XOR_X ancillary is not like the other ancillary data
> >instructions since it XORs A with X while all the others replace A with
> >some loaded value.  All the BPF JITs fail to clear A if this is used as
> >the first instruction in a filter.  This was found using american fuzzy
> >lop.
> >
> >Add a helper to determine if A needs to be cleared given the first
> >instruction in a filter, and use this in the JITs.  Except for ARM, the
> >rest have only been compile-tested.
> >
> >Fixes: 3480593131e0 ("net: filter: get rid of BPF_S_* enum")
> >Signed-off-by: Rabin Vincent <rabin@rab.in>
> 
> Excellent catch, thanks a lot! The fix looks good to me and should
> go to -net tree.
> 
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

good catch indeed.
Classic bpf jits didn't have much love. Great to see this work.

Acked-by: Alexei Starovoitov <ast@kernel.org>
