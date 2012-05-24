From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 01/17] netfilter: add struct nf_proto_net for register
 l4proto sysctl
Date: Thu, 24 May 2012 16:38:54 +0200
Message-ID: <20120524143854.GA15898@1984>
References: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1336985547-31960-2-git-send-email-gaofeng@cn.fujitsu.com>
 <20120523101200.GA2836@1984>
 <4FBD9076.6060309@cn.fujitsu.com>
 <20120524095859.GC13091@1984>
 <4FBE1372.60206@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitus.com>
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4FBE1372.60206@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 24, 2012 at 06:54:42PM +0800, Gao feng wrote:
[...]
> >>> I don't see why we need this new field.
> >>>
> >>> It seems to be set to 1 in each structure that has set:
> >>>
> >>> .ctl_compat_table
> >>>
> >>> to non-NULL. So, it's redundant.
> >>>
> >>> Moreover, you already know from the protocol tracker itself if you
> >>> have to allocate the compat ctl table or not.
> >>>
> >>> In other words: You set compat to 1 for nf_conntrack_l4proto_generic.
> >>> Then, you pass that compat value to generic_init_net via ->inet_net
> >>> again, but this information (that determines if the compat has to be
> >>> done or not) is already in the scope of the protocol tracker.
> >>>
> >>
> >> because some protocols such l4proto_tcp6 and l4proto_tcp use the same init_net
> >> function. the l4proto_tcp6 doesn't need compat sysctl, so we should use this new
> >> field to identify if we should kmemdup compat_sysctl_table.
> > 
> > Then, could you use two init_net functions? one for TCP for IPv4 and another
> > for TCP for IPv6?
> 
> Of cause, if you prefer to impletment it in this way.

If this removes the .compat field that you added, then use two
init_net functions, yes.
