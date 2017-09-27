From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH v2 0/3] Check user supplied interface name
 lengths
Date: Wed, 27 Sep 2017 08:42:49 +0100
Message-ID: <20170927084249.0591ee3a@shemminger-XPS-13-9360>
References: <20170926163548.24347-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:50051 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751287AbdI0Hmy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 03:42:54 -0400
Received: by mail-wm0-f44.google.com with SMTP id r74so14860363wme.4
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 00:42:54 -0700 (PDT)
In-Reply-To: <20170926163548.24347-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Sep 2017 18:35:45 +0200
Phil Sutter <phil@nwl.cc> wrote:

> This series adds explicit checks for user-supplied interface names to
> make sure their length fits Linux's requirements.
> 
> The first two patches simplify interface name parsing in some places -
> these are side-effects of working on the actual implementation provided
> in patch three.
> 
> Changes since v1:
> - Patches 1 and 2 introduced.
> - Changes to patch 3 are listed in there.
> 
> Phil Sutter (3):
>   ip{6,}tunnel: Avoid copying user-supplied interface name around
>   tc: flower: No need to cache indev arg
>   Check user supplied interface name lengths
> 
>  include/utils.h |  1 +
>  ip/ip6tunnel.c  |  9 +++++----
>  ip/ipl2tp.c     |  3 ++-
>  ip/iplink.c     | 27 ++++++++-------------------
>  ip/ipmaddr.c    |  1 +
>  ip/iprule.c     |  4 ++++
>  ip/iptunnel.c   | 27 +++++++++++++--------------
>  ip/iptuntap.c   |  4 +++-
>  lib/utils.c     | 10 ++++++++++
>  misc/arpd.c     |  1 +
>  tc/f_flower.c   |  6 ++----
>  11 files changed, 50 insertions(+), 43 deletions(-)
> 

I like the idea, and checking arguments is good.
Why not merge the check and copy and put in lib/utils.c

int get_ifname(char *name, const char *arg)
{
...
