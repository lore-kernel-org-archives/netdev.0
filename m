From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: Re: ctnetlink loop
Date: Wed, 8 Dec 2010 21:31:21 +0100
Message-ID: <20101208203121.GB23668@mail.eitzenberger.org>
References: <20101208.095020.245408999.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101208.095020.245408999.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> Holger, this replay -EAGAIN loop in nfnetlink processing was added by
> Pablo to handle module loading properly, I think.  So it might not be
> safe to just unilaterally remove it.

thanks for your reply!

Pablo, do we really need the replay loop really?  I now have several
boxes with problems due to this replay.  'perf report' always gives me
something like:

      18.88%            ulogd  [kernel]
  [k] __nla_put
      10.73%            ulogd  [kernel]
  [k] nla_parse
       8.72%            ulogd  [kernel]
  [k] __nla_reserve
       6.64%            ulogd  [kernel]
  [k] nla_put
       5.14%            ulogd  [kernel]
  [k] validate_nla
       5.03%            ulogd  [kernel]
  [k] pskb_expand_head
       4.92%            ulogd  [kernel]
  [k] ctnetlink_fill_info [nf_conntrack_netlink]
       3.07%            ulogd  [kernel]
  [k] skb_put
       3.03%            ulogd  [kernel]
  [k] ctnetlink_dump_counters [nf_conntrack

And 'strace' shows me that ulogd is stuck in its 'select' call.

 /holger
