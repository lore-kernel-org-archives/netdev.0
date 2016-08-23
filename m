From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH iproute2 0/4] improve initialization of genl handle
Date: Tue, 23 Aug 2016 11:18:01 +0200
Message-ID: <20160823091801.GG8820@orbyte.nwl.cc>
References: <cover.1471356460.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:51685 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751567AbcHWJ2J (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 Aug 2016 05:28:09 -0400
Content-Disposition: inline
In-Reply-To: <cover.1471356460.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 16, 2016 at 04:26:54PM +0200, Sabrina Dubroca wrote:
> This patchset fixes several issues for users of genetlink:
> 
>  - Duplicated code for initialization of a genl handle.
>    All users of genl must open a socket and resolve the family, and
>    use the same code to do that.
>    Solution: add a library function.
> 
>  - genl family resolution fails when the module that handles this
>    family is not loaded yet.
>    This means that if we try to initialize the genl handle early in
>    handling the command, we cannot display usage, because we fail hard
>    when trying to resolve the genl family.
>    Solution: move the genl handle initialization after handling the
>    `ip * help` case.
> 
> Sabrina Dubroca (4):
>   libgenl: introduce genl_init_handle
>   macsec: show usage even if the module is not available
>   fou: show usage even if the module is not available
>   ila: show usage even if the module is not available
> 
>  include/libgenl.h |  2 ++
>  ip/ipfou.c        | 20 ++++++--------------
>  ip/ipila.c        | 19 ++++++-------------
>  ip/ipl2tp.c       | 12 ++----------
>  ip/ipmacsec.c     | 20 +++-----------------
>  ip/tcp_metrics.c  | 14 +++-----------
>  lib/libgenl.c     | 17 +++++++++++++++++
>  7 files changed, 39 insertions(+), 65 deletions(-)

Series:
Acked-by: Phil Sutter <phil@nwl.cc>
