From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net 2/2] conntrack: enable to tune gc parameters
Date: Fri, 14 Oct 2016 12:53:27 +0200
Message-ID: <20161014105327.GA8655@salvia>
References: <1476094704-17452-1-git-send-email-nicolas.dichtel@6wind.com>
 <1476094704-17452-3-git-send-email-nicolas.dichtel@6wind.com>
 <20161010140424.GB21057@breakpoint.cc>
 <cdda5290-c49c-e841-6ba5-10b30fd04fc0@6wind.com>
 <20161013204338.GA32449@breakpoint.cc>
 <f1df137d-7278-f6fb-3237-1bd20afadb48@6wind.com>
 <20161014103726.GA10404@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>, davem@davemloft.net,
        netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:46296 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751605AbcJNKxe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 14 Oct 2016 06:53:34 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 4C2099B801
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 12:53:31 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 3E3EFDA7FA
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 12:53:31 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 04108DA847
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 12:53:29 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20161014103726.GA10404@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 14, 2016 at 12:37:26PM +0200, Florian Westphal wrote:
> Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
> > Le 13/10/2016 à 22:43, Florian Westphal a écrit :
[...]
> > > (Or cause too many useless scans)
> > > 
> > > Another idea worth trying might be to get rid of the max cap and
> > > instead break early in case too many jiffies expired.
> > > 
> > > I don't want to add sysctl knobs for this unless absolutely needed; its already
> > > possible to 'force' eviction cycle by running 'conntrack -L'.
> > > 
> > Sure, but this is not a "real" solution, just a workaround.
> > We need to find a way to deliver conntrack deletion events in a reasonable
> > delay, whatever the traffic on the machine is.
> 
> Agree, but that depends on what 'reasonable' means and what kind of
> uneeded cpu churn we're willing to add.
> 
> We can add a sysctl for this but we should use a low default to not do
> too much unneeded work.
> 
> So what about your original patch, but only add
> 
> nf_conntrack_gc_interval
> 
> (and also add instant-resched in case entire budget was consumed)?

I would prefer not to expose sysctl knobs, if we don't really know
what good default values are good, then we cannot expect our users to
know this for us.

I would go tune this in a way that this resembles to the previous
behaviour.
