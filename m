From: Olivier Brunel <jjk@jjacky.com>
Subject: Re: Bug w/ (policy) routing
Date: Mon, 2 Jan 2017 18:05:48 +0100
Message-ID: <20170102180548.1390a09c@jjacky.com>
References: <20161231000006.17677918@jjacky.com>
        <3575dc1f-d536-20d2-24b9-a1e95a5c795b@cumulusnetworks.com>
        <20170101205238.426803f4@jjacky.com>
        <c59bcb99-39d1-3b47-7787-dd4d805eb4f6@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 23-29-69-116.static.gorillaservers.com ([23.29.69.116]:43805
        "EHLO mail.jjacky.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
        with ESMTP id S1751739AbdABRHK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 12:07:10 -0500
In-Reply-To: <c59bcb99-39d1-3b47-7787-dd4d805eb4f6@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2 Jan 2017 09:48:12 -0700
David Ahern <dsa@cumulusnetworks.com> wrote:

> On 1/1/17 12:52 PM, Olivier Brunel wrote:
> > Indeed, if I first delete the rule for lookup local and recreate it
> > w/ higher prio than my "lookup 50", then no more issue.  
> 
> After the unshare or when creating a new network namespace, bringing
> the lo device up will create the local table and the rest of the
> commands will work properly. ie., instead of moving the local rule
> you can run:

Indeed, and that's a much better solution for me, since I bring lo up
anyways, I might as well do it first. Thank you.


> unshare -n bash
> 
> ip li set lo up
> ip rule add table 50 prio 50
> ip link add test type veth peer name test2
> ...
> 
> -----
> 
> Alex: 
> 
> The order of commands is influencing whether the unmerge succeeds or
> not which is wrong. I took a quick look and I don't see a simple
> solution to this. Effectively:
> 
> Adding a rule before bringing up any interface does not unmerge the
> tables: $ unshare -n bash
> $ ip rule add table 50 prio 50
> $ ip li set lo up
> 
> In fib_unmerge(), fib_new_table(net, RT_TABLE_LOCAL) returns null.
> 
> 
> Where the reverse order works:
> $ unshare -n bash
> $ ip li set lo up
> $ ip rule add table 50 prio 50
> 
> David
