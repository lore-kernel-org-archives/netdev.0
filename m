From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH 0/6] strlcpy() and strlcat() for iproute2
Date: Fri, 1 Sep 2017 12:12:17 -0700
Message-ID: <20170901121217.33e93cf9@xeon-e3>
References: <20170901165256.21459-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:33135 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751715AbdIATMU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 15:12:20 -0400
Received: by mail-pf0-f177.google.com with SMTP id n73so3012206pfj.0
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 12:12:20 -0700 (PDT)
In-Reply-To: <20170901165256.21459-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  1 Sep 2017 18:52:50 +0200
Phil Sutter <phil@nwl.cc> wrote:

> The following series adds my own implementations of strlcpy() and
> strlcat() in patch 1 and changes the code to make use of them in the
> following patches but the last two: Patch 5 just eliminates a line of
> useless code I found while searching for potential users of the
> introduced functions, patch 6 sanitizes a call to strncpy() in
> misc/lnstat_util.c without using strlcpy() since lnstat is not being
> linked against libutil.
> 
> I implemented both functions solely based on information in libbsd's man
> pages, so they are safe to be released under the GPL.
> 
> Phil Sutter (6):
>   utils: Implement strlcpy() and strlcat()
>   Convert the obvious cases to strlcpy()
>   Convert harmful calls to strncpy() to strlcpy()
>   ipxfrm: Replace STRBUF_CAT macro with strlcat()
>   tc_util: No need to terminate an snprintf'ed buffer
>   lnstat_util: Make sure buffer is NUL-terminated
> 
>  genl/ctrl.c           |  2 +-
>  include/utils.h       |  3 +++
>  ip/ipnetns.c          |  3 +--
>  ip/iproute_lwtunnel.c |  3 +--
>  ip/ipvrf.c            |  5 ++---
>  ip/ipxfrm.c           | 21 +++++----------------
>  ip/xfrm_state.c       |  2 +-
>  lib/bpf.c             |  3 +--
>  lib/fs.c              |  3 +--
>  lib/inet_proto.c      |  3 +--
>  lib/utils.c           | 19 +++++++++++++++++++
>  misc/lnstat_util.c    |  3 ++-
>  misc/ss.c             |  3 +--
>  tc/em_ipset.c         |  3 +--
>  tc/tc_util.c          |  1 -
>  15 files changed, 40 insertions(+), 37 deletions(-)
> 

Applied, thanks.
