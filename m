From: "Yang, Yi" <yi.y.yang@intel.com>
Subject: Re: [ovs-dev] [PATCH net-next v9] openvswitch: enable NSH support
Date: Tue, 26 Sep 2017 13:02:15 +0800
Message-ID: <20170926050215.GB5896@localhost.localdomain>
References: <1506348969-6233-1-git-send-email-yi.y.yang@intel.com>
 <20170925192842.GD1786@dev-rhel7>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        "jbenc@redhat.com" <jbenc@redhat.com>,
        "davem@davemloft.net" <davem@davemloft.net>
To: Eric Garver <e@erig.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:58400 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752952AbdIZFG3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 01:06:29 -0400
Content-Disposition: inline
In-Reply-To: <20170925192842.GD1786@dev-rhel7>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 26, 2017 at 03:28:42AM +0800, Eric Garver wrote:
> On Mon, Sep 25, 2017 at 10:16:09PM +0800, Yi Yang wrote:
> > +
> > +	length = nsh_hdr_len(nsh_hdr);
> > +	skb_pull(skb, length);
> 
> Do you need to verify you can actually pull length bytes? I don't see
> any guarantee.

I have added skb length check in pop_nsh, so that can verify this.

> > +	err = skb_ensure_writable(skb, skb_network_offset(skb) +
> > +				  sizeof(struct nshhdr));
> 
> This calls pskb_may_pull(), but you're not pulling any data here.

set_ipv4 and set_ipv6 also used skb_ensure_writable to check if skb
has enough header length, they didn't call skb_pull in the following
part, so I think this is ok.

I have sent out v10 to fix all of your comments for v9, please help
review v10, thanks a lot.
