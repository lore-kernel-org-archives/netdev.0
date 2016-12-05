From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next] netfilter: xt_bpf: support ebpf
Date: Tue, 6 Dec 2016 00:22:14 +0100
Message-ID: <20161205232214.GA15825@salvia>
References: <1480969684-74414-1-git-send-email-willemdebruijn.kernel@gmail.com>
 <1480972006.18162.559.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161205213001.GA16819@breakpoint.cc>
 <20161205223415.GA14689@salvia>
 <20161205230055.GA15379@salvia>
 <CAF=yD-Jk4W+zU=tdixWe3LPGcFp-sANxXLLoQTRvrkN_3=a9uw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org,
        Network Development <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Willem de Bruijn <willemb@google.com>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34932 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751373AbcLEXWf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Dec 2016 18:22:35 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id BBB5796ECD
        for <netdev@vger.kernel.org>; Tue,  6 Dec 2016 00:22:32 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id A1372A0FC1
        for <netdev@vger.kernel.org>; Tue,  6 Dec 2016 00:22:32 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 8B9BCA0FC0
        for <netdev@vger.kernel.org>; Tue,  6 Dec 2016 00:22:30 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <CAF=yD-Jk4W+zU=tdixWe3LPGcFp-sANxXLLoQTRvrkN_3=a9uw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 05, 2016 at 06:06:05PM -0500, Willem de Bruijn wrote:
[...]
> Eric also suggests a private variable to avoid being subject to
> changes to PATH_MAX. Then we can indeed also choose an arbitrary lower
> length than current PATH_MAX.

Good.

> FWIW, there is a workaround for users with deeply nested paths: the
> path passed does not have to be absolute. It is literally what is
> passed on the command line to iptables right now, including relative
> addresses.

If iptables userspace always expects to have the bpf file repository
in some given location (suggesting to have a directory that we specify
at ./configure time, similar to what we do with connlabel.conf), then
I think we can rely on relative paths. Would this be flexible enough
for your usecase?
