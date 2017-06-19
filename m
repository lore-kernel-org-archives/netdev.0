From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next] netns: add and use net_ns_barrier
Date: Mon, 19 Jun 2017 19:10:40 +0200
Message-ID: <20170619171040.GB4975@salvia>
References: <20170530093812.10712-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        "Eric W. Biederman" <ebiederm@xmission.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56098 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750863AbdFSRKp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Jun 2017 13:10:45 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 1CD802E7846
        for <netdev@vger.kernel.org>; Mon, 19 Jun 2017 19:10:35 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 067A3FF6F2
        for <netdev@vger.kernel.org>; Mon, 19 Jun 2017 19:10:35 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 182FE10078C
        for <netdev@vger.kernel.org>; Mon, 19 Jun 2017 19:10:33 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20170530093812.10712-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 30, 2017 at 11:38:12AM +0200, Florian Westphal wrote:
> Quoting Joe Stringer:
>   If a user loads nf_conntrack_ftp, sends FTP traffic through a network
>   namespace, destroys that namespace then unloads the FTP helper module,
>   then the kernel will crash.
> 
> Events that lead to the crash:
> 1. conntrack is created with ftp helper in netns x
> 2. This netns is destroyed
> 3. netns destruction is scheduled
> 4. netns destruction wq starts, removes netns from global list
> 5. ftp helper is unloaded, which resets all helpers of the conntracks
> via for_each_net()
> 
> but because netns is already gone from list the for_each_net() loop
> doesn't include it, therefore all of these conntracks are unaffected.
> 
> 6. helper module unload finishes
> 7. netns wq invokes destructor for rmmod'ed helper

Applied, thanks everyone.
