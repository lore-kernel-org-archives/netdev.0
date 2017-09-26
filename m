From: Eric Garver <e@erig.me>
Subject: Re: [ovs-dev] [PATCH net-next v9] openvswitch: enable NSH support
Date: Tue, 26 Sep 2017 16:59:36 -0400
Message-ID: <20170926205936.GE1786@dev-rhel7>
References: <1506348969-6233-1-git-send-email-yi.y.yang@intel.com>
 <20170925192842.GD1786@dev-rhel7>
 <20170926050215.GB5896@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "jbenc@redhat.com" <jbenc@redhat.com>,
        "davem@davemloft.net" <davem@davemloft.net>
To: "Yang, Yi" <yi.y.yang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53562 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1030665AbdIZU7c (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 16:59:32 -0400
Content-Disposition: inline
In-Reply-To: <20170926050215.GB5896@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 26, 2017 at 01:02:15PM +0800, Yang, Yi wrote:
> On Tue, Sep 26, 2017 at 03:28:42AM +0800, Eric Garver wrote:
> > On Mon, Sep 25, 2017 at 10:16:09PM +0800, Yi Yang wrote:
> > > +
> > > +	length = nsh_hdr_len(nsh_hdr);
> > > +	skb_pull(skb, length);
> > 
> > Do you need to verify you can actually pull length bytes? I don't see
> > any guarantee.
> 
> I have added skb length check in pop_nsh, so that can verify this.

That doesn't help other code that may call skb_pop_nsh(). skb_vlan_pop()
calls skb_ensure_writable() which seems like the right thing to do.
