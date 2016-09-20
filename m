From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v6 5/6] net: ipv4, ipv6: run cgroup eBPF egress programs
Date: Tue, 20 Sep 2016 16:29:31 +0200
Message-ID: <20160920142931.GA31438@salvia>
References: <1474303441-3745-1-git-send-email-daniel@zonque.org>
 <1474303441-3745-6-git-send-email-daniel@zonque.org>
 <20160919191910.GA984@salvia>
 <ac88bb4c-ab7c-1f74-c7fd-79e523b50ae4@zonque.org>
 <20160919203533.GA888@salvia>
 <83afdc54-1bbe-3530-e5fd-b74fefe9a042@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: htejun@fb.com, daniel@iogearbox.net, ast@fb.com,
        davem@davemloft.net, kafai@fb.com, fw@strlen.de, harald@redhat.com,
        netdev@vger.kernel.org, sargun@sargun.me, cgroups@vger.kernel.org
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58062 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753873AbcITO3r (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 10:29:47 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id BF57C2791C0
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 16:29:44 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id ACA99DA916
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 16:29:44 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 71A67DA858
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 16:29:36 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <83afdc54-1bbe-3530-e5fd-b74fefe9a042@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 19, 2016 at 10:56:14PM +0200, Daniel Mack wrote:
[...]
> Why would we artificially limit the use-cases of this implementation if
> the way it stands, both filtering and introspection are possible?

Why should we place infrastructure in the kernel to filter packets so
late, and why at postrouting btw, when we can do this way earlier
before any packet is actually sent? No performance impact, no need for
skbuff allocation and *no cycles wasted to evaluate if every packet is
wanted or not*.
