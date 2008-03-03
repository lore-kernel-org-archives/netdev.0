From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [rfc][patch 1/3] slub: fix small HWCACHE_ALIGN alignment
Date: Mon, 3 Mar 2008 11:44:07 +0200
Message-ID: <84144f020803030144v17544936ybe222e8f4850dfa2@mail.gmail.com>
References: <20080303093449.GA15091@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, "David Miller" <davem@davemloft.net>,
	"Christoph Lameter" <clameter@engr.sgi.com>,
	"Eric Dumazet" <dada1@cosmosbay.com>
To: "Nick Piggin" <npiggin@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.185]:3211 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753465AbYCCJoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 04:44:08 -0500
Received: by rv-out-0910.google.com with SMTP id k20so3793282rvb.1
        for <netdev@vger.kernel.org>; Mon, 03 Mar 2008 01:44:07 -0800 (PST)
In-Reply-To: <20080303093449.GA15091@wotan.suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Nick,

On Mon, Mar 3, 2008 at 11:34 AM, Nick Piggin <npiggin@suse.de> wrote:
>  SLUB should pack even small objects nicely into cachelines if that is what
>  has been asked for. Use the same algorithm as SLAB for this.

The patches look good but this changelog is missing context. Why do we
want to do this?

On Mon, Mar 3, 2008 at 11:34 AM, Nick Piggin <npiggin@suse.de> wrote:
>  @@ -1896,12 +1896,15 @@ static unsigned long calculate_alignment
>          * specified alignment though. If that is greater
>          * then use it.
>          */

You might want to fix the above comment too.

>  -       if ((flags & SLAB_HWCACHE_ALIGN) &&
>  -                       size > cache_line_size() / 2)
>  -               return max_t(unsigned long, align, cache_line_size());
>  +       if (flags & SLAB_HWCACHE_ALIGN) {
>  +               unsigned long ralign = cache_line_size();
>  +               while (size <= ralign / 2)
>  +                       ralign /= 2;
>  +               align = max(align, ralign);
>  +       }
