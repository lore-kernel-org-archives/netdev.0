From: "Yang, Yi" <yi.y.yang@intel.com>
Subject: Re: [PATCH net-next v13] openvswitch: enable NSH support
Date: Mon, 30 Oct 2017 09:34:22 +0800
Message-ID: <20171030013421.GA4054@localhost.localdomain>
References: <1509003916-31897-1-git-send-email-yi.y.yang@intel.com>
 <20171030.100134.1999494058214685235.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dev@openvswitch.org, jbenc@redhat.com,
        e@erig.me, pshelar@ovn.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:65093 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751221AbdJ3BjG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 29 Oct 2017 21:39:06 -0400
Content-Disposition: inline
In-Reply-To: <20171030.100134.1999494058214685235.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 30, 2017 at 10:01:34AM +0900, David Miller wrote:
> From: Yi Yang <yi.y.yang@intel.com>
> Date: Thu, 26 Oct 2017 15:45:16 +0800
> 
> > OVS master and 2.8 branch has merged NSH userspace
> > patch series, this patch is to enable NSH support
> > in kernel data path in order that OVS can support
> > NSH in compat mode by porting this.
> > 
> > Signed-off-by: Yi Yang <yi.y.yang@intel.com>
> 
> One small request for function naming:
> 
> > diff --git a/include/net/nsh.h b/include/net/nsh.h
> > index a1eaea2..7dcf377 100644
> > --- a/include/net/nsh.h
> > +++ b/include/net/nsh.h
> > @@ -304,4 +304,7 @@ static inline void nsh_set_flags_ttl_len(struct nshhdr *nsh, u8 flags,
> >  			NSH_FLAGS_MASK | NSH_TTL_MASK | NSH_LEN_MASK);
> >  }
> >  
> > +int skb_push_nsh(struct sk_buff *skb, const struct nshhdr *pushed_nh);
> > +int skb_pop_nsh(struct sk_buff *skb);
> > +
> >  #endif /* __NET_NSH_H */
> 
> All functions named "skb_*" should be core SKB handling functions found
> and implemented in include/linux/skbuff.h and net/core/skbuff.c
> 
> Protocol specific helpers like this should be named "$PROTOCOL_NAME_*"
> so please renamed these something like "nsh_header_push()" and
> "nsh_header_pop()".

Dave, thank for your comments, I have changed skb_push_nsh to nsh_push and
changed skb_pop_nsh to nsh_pop, posted v14, please review, thanks.

> 
> Thank you.
