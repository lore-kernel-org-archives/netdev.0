From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v3 net-next 0/4] bpf: BPF for lightweight tunnel
 encapsulation
Date: Tue, 29 Nov 2016 15:58:02 +0100
Message-ID: <20161129145802.GA16856@pox.localdomain>
References: <cover.1480424542.git.tgraf@suug.ch>
 <50764658-4bf7-966b-bc61-d6840d7c03f2@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        tom@herbertland.com, roopa@cumulusnetworks.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f174.google.com ([209.85.210.174]:35737 "EHLO
        mail-wj0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933770AbcK2O6K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 09:58:10 -0500
Received: by mail-wj0-f174.google.com with SMTP id v7so147492183wjy.2
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 06:58:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <50764658-4bf7-966b-bc61-d6840d7c03f2@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hannes,

On 11/29/16 at 03:15pm, Hannes Frederic Sowa wrote:
> Did you look at the cgroup based hooks which were added recently in
> ip_finish_output for cgroup ebpf support and in general the cgroup bpf
> subsystem. Does some of this solve the problem for you already? Would be
> interesting to hear your opinion on that.

What I'm looking for is the ability to collect statistics and generate
samples for a subset of the traffic, e.g. all intra data center
traffic, all packets hitting the default route in a network namespace,
all packets which use a dst tying a certain endpoint to particular TCP
metrics. For the examples above, LWT provides a very intuitive and
natural way to do so while amortizing the cost of the route lookup
which is required anyway.

The cgroup hook provides similar semantics but if the application
context is of interest. Obviously, tasks in a cgroup may be sharing
routes so I can't use it as a replacement. However, using the two in
combination will become highly useful as it allows to gather statistics
individually for both application context and routing context and then
aggregate them to see how applications are using different network
segments.

Aside from the different context matching, the cgroup hook will not
allow to modify the packet as the lwtunnel_xmit() post
ip_finish_output does.
