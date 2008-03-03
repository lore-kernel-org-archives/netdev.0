From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [rfc][patch 3/3] use SLAB_ALIGN_SMP
Date: Mon, 3 Mar 2008 15:53:15 +0200
Message-ID: <84144f020803030553s35a40dd8yf88585ccd5a599fd@mail.gmail.com>
References: <20080303093449.GA15091@wotan.suse.de>
	 <20080303093624.GC15091@wotan.suse.de>
	 <47CBCAB0.2040604@cosmosbay.com>
	 <20080303124142.GB13138@wotan.suse.de> <47CBF683.10201@cosmosbay.com>
	 <20080303134622.GD13138@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Eric Dumazet" <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, "David Miller" <davem@davemloft.net>,
	"Christoph Lameter" <clameter@engr.sgi.com>
To: "Nick Piggin" <npiggin@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.183]:38268 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752772AbYCCNxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 08:53:17 -0500
Received: by el-out-1112.google.com with SMTP id v27so28850ele.17
        for <netdev@vger.kernel.org>; Mon, 03 Mar 2008 05:53:16 -0800 (PST)
In-Reply-To: <20080303134622.GD13138@wotan.suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, Mar 3, 2008 at 3:46 PM, Nick Piggin <npiggin@suse.de> wrote:
>  > Maybe we need to use three flags to separate the meanings ?
>  >
>  > SLAB_HINT_SMP_ALIGN
>  > SLAB_HINT_HWCACHE_ALIGN
>  > SLAB_HWCACHE_ALIGN /* strong requirement that two objects dont share a
>  > cache line */
>
>  Possibly, but I'm beginning to prefer that strong requirements should
>  request the explicit alignment (they can even use cache_line_size() after
>  Pekka's patch to make it generic). I don't like how the name implies
>  that you get a guarantee, however I guess in practice people are using it
>  more as a hint (or because they vaguely hope it makes their code run
>  faster :))

At least historically SLAB_HWCACHE_ALIGN has been just a hint,
although slab tries very hard to satisfy it (see the comments in
mm/slab.c). Why do we need stronger guarantees than that, btw?
