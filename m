From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/6] neigh cleanups and fixes
Date: Fri, 15 May 2015 05:14:42 -0700
Message-ID: <1431692082.27831.92.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431672946-300-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei@purestorage.com,
	joern@purestorage.com, ja@ssi.bg, davem@davemloft.net
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:35273 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934130AbbEOMOo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 08:14:44 -0400
Received: by iesa3 with SMTP id a3so20582426ies.2
        for <netdev@vger.kernel.org>; Fri, 15 May 2015 05:14:43 -0700 (PDT)
In-Reply-To: <1431672946-300-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-05-15 at 14:55 +0800, Ying Xue wrote:
> The series aims to clean up several mistakes especially to correct
> the usage of neigh timer. But before doing them, we have to resolve
> a crash issue discussed in the thread[1].
> 
> [1] http://www.spinics.net/lists/netdev/msg323883.html
> 
> Ying Xue (6):
>   net: fix a double free issue for neighbour entry
>   neigh: fix a possible leak issue of neigh entry
>   neigh: don't delete neighbour time in neigh_destroy
>   neigh: align the usage of neigh timer with one of sock timer
>   neigh: neigh dead and timer variables should be protected under its
>     lock
>   neigh: use standard interface to modify timer
> 
>  net/core/neighbour.c |   39 +++++++++++++++++++++++----------------
>  net/ipv4/ip_output.c |    2 +-
>  2 files changed, 24 insertions(+), 17 deletions(-)
> 

NACK for the whole series.

Your fixes make no sense, adding race conditions of all sorts.

atomic_read() by definition are unsafe.

Make a single and logical change, do not throw random patches like that,
ignoring feedback you already got.

Thanks.
