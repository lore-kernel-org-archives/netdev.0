From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v3] iproute2: build nsid-name cache only for commands
 that need it
Date: Sun, 9 Oct 2016 18:57:40 -0700
Message-ID: <20161009185740.31727206@xeon-e3>
References: <20160920060123.GA17211@toys.tundra.dog-lvm.novalocal>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com,
        vadim4j@gmail.com
To: Anton Aksola <aakso@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33665 "EHLO
        mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751441AbcJJB5k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2016 21:57:40 -0400
Received: by mail-pa0-f51.google.com with SMTP id vu5so7972617pab.0
        for <netdev@vger.kernel.org>; Sun, 09 Oct 2016 18:57:40 -0700 (PDT)
In-Reply-To: <20160920060123.GA17211@toys.tundra.dog-lvm.novalocal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Sep 2016 06:01:27 +0000
Anton Aksola <aakso@iki.fi> wrote:

> The calling of netns_map_init() before command parsing introduced
> a performance issue with large number of namespaces.
> 
> As commands such as add, del and exec do not need to iterate through
> /var/run/netns it would be good not no build the cache before executing
> these commands.
> 
> Example:
> unpatched:
> time seq 1 1000 | xargs -n 1 ip netns add
> 
> real    0m16.832s
> user    0m1.350s
> sys    0m15.029s
> 
> patched:
> time seq 1 1000 | xargs -n 1 ip netns add
> 
> real    0m3.859s
> user    0m0.132s
> sys    0m3.205s
> 
> Signed-off-by: Anton Aksola <aakso@iki.fi>
> ---
>  ip/ip_common.h                            |  1 +
>  ip/ipmonitor.c                            |  1 +
>  ip/ipnetns.c                              | 31 ++++++++++++++++++++++---------
>  testsuite/tests/ip/netns/set_nsid.t       | 22 ++++++++++++++++++++++
>  testsuite/tests/ip/netns/set_nsid_batch.t | 18 ++++++++++++++++++
>  5 files changed, 64 insertions(+), 9 deletions(-)
>  create mode 100755 testsuite/tests/ip/netns/set_nsid.t
>  create mode 100755 testsuite/tests/ip/netns/set_nsid_batch.t
> 

Applied to net-next (ie for 4.9)
