From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: Force fake conntrack entry to be at least 8
 bytes aligned
Date: Mon, 13 Mar 2017 13:33:32 +0100
Message-ID: <20170313123332.GA6790@salvia>
References: <20170311002526.1d21e750@gandalf.local.home>
 <20170311091222.GA24201@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Steven Rostedt (VMware)" <rostedt@goodmis.org>,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        coreteam@netfilter.org, netfilter-devel@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60102 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751557AbdCMMdu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Mar 2017 08:33:50 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id CC36C65B00
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 13:33:47 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 1BB1EA8256
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 13:33:47 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 2F7ABDA247
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 13:33:37 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20170311091222.GA24201@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 11, 2017 at 10:12:22AM +0100, Florian Westphal wrote:
> Steven Rostedt (VMware) <rostedt@goodmis.org> wrote:
> > Since the nfct and nfctinfo have been combined, the nf_conn structure
> > must be at least 8 bytes aligned, as the 3 LSB bits are used for the
> > nfctinfo. But there's a fake nf_conn structure to denote untracked
> > connections, which is created by a PER_CPU construct. This does not
> > guarantee that it will be 8 bytes aligned and can break the logic in
> > determining the correct nfctinfo.
> > 
> > I triggered this on a 32bit machine with the following error:
> [..]
> 
> Ugh.  Originally I had planned to also submit followup changes
> to get rid of the untracked objects but that part got delayed.
> 
> > By using DEFINE/DECLARE_PER_CPU_ALIGNED we can enforce at least 8 byte
> > alignment as all cache line sizes are at least 8 bytes or more.
> 
> Thanks for fixing this!
> 
> Acked-by: Florian Westphal <fw@strlen.de>

Applied, thanks.
