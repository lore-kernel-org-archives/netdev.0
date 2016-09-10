From: Quentin Barnes <qbarnes@gmail.com>
Subject: Re: iptables, conntrack, and the raw table vs. L3DSR
Date: Sat, 10 Sep 2016 18:49:05 -0500
Message-ID: <CAKjHkpCJr4_mmZqdjSvcTp+mq2cV3WUvsA==Boc8dK+JXrL69A@mail.gmail.com>
References: <20160827215538.GA36125@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:34186 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752258AbcIJXtI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Sep 2016 19:49:08 -0400
Received: by mail-lf0-f47.google.com with SMTP id u14so66346908lfd.1
        for <netdev@vger.kernel.org>; Sat, 10 Sep 2016 16:49:08 -0700 (PDT)
In-Reply-To: <20160827215538.GA36125@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Being unsuccessful at getting help so far, can anyone think of who or
where else I could ask for help on this issue?

On Sat, Aug 27, 2016 at 4:55 PM, Quentin Barnes <qbarnes@gmail.com> wrote:
> Several years ago, I wrote an iptables module that rewrites packets'
> destination addresses based on the value in the DSCP field to
> implement Layer 3 Direct Server Return (L3DSR).  The main code of
> the iptables target module you can find here:
> https://github.com/yahoo/l3dsr/blob/master/linux/kmod-xt/xt_DADDR.c
>
> The iptable-daddr module has been in production since I wrote it
> with some limitations.  One of those limitations is it doesn't
> work well with conntrack modules.  I believe that's from the daddr
> rewriting confuses conntrack since changing a packet's daddr changes
> its 4-tuple not allowing conntrack to track a connection.
>
> Someone recently suggested I change the module from the "mangle"
> table to "raw", so it can be put in the prerouting chain ahead of
> conntrack.  That would let conntrack see the packet after its daddr
> update.  This approach seems to work fine in a test case letting
> L3DSR and conntrack apparently work in concert, but has me concerned
> that there might be unforeseen negative side-effects from using the
> raw table for doing mangling work.
>
> Can anyone think of any issues with having a mangle target module be
> invoked from the raw table?
>
> Or as an alternative if necessary, is there a possible/rational way
> to leave the module in the mangle table and then inform conntrack
> about the packet's daddr alteration?
>
> Quentin
