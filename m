From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/2] netlink: netlink_dump_start may take data pointer
 for callbacks
Date: Sat, 25 Feb 2012 00:18:03 +0100
Message-ID: <20120224231803.GA13163@1984>
References: <1330121648-2956-1-git-send-email-pablo@netfilter.org>
 <1330121648-2956-2-git-send-email-pablo@netfilter.org>
 <20120224.174726.1107636579816083287.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120224.174726.1107636579816083287.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 24, 2012 at 05:47:26PM -0500, David Miller wrote:
> From: pablo@netfilter.org
> Date: Fri, 24 Feb 2012 23:14:07 +0100
> 
> > From: Pablo Neira Ayuso <pablo@netfilter.org>
> > 
> > This patch modifies the netlink_dump_start function to take one
> > generic pointer to data. This pointer can be used inside the
> > dump() and done() callbacks via cb->data.
> > 
> > Netfilter is going to use this patch to provide filtered dumps
> > to user-space. This is specifically interesting in ctnetlink that
> > may handle lots of conntrack entries. We can save precious
> > cycles by skipping the conversion to TLV format of conntrack
> > entries that are not interesting for user-space.
> > 
> > More specifically, ctnetlink will include one operation to allow
> > to filter the dumping of conntrack entries by ctmark values.
> > 
> > Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> 
> This isn't really your fault but netlink_dump_start() has an
> enormous number of arguments.
> 
> Several of them are zero or NULL in all except one special situation.
> 
> An entire argument is a lot of overhead for one situation to impose on
> all the others.
> 
> I have no objection to the data callback scheme, it's just that
> the argument list of this interface is getting out of control.
> 
> Usually, in situations like this, we have some control structure
> that holds all the control state and we pass that in instead.
> 
> 	struct netlink_dump_control c = { .dump = dump, .done = done, ... };
> 
> 	netlink_dump_start(..., &c);
> 
> It could be perhaps used here to get things back under control.

OK, I'll send a patch to make it like this.
