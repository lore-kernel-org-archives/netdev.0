From: "Yang, Yi" <yi.y.yang@intel.com>
Subject: Re: [PATCH net-next v9] openvswitch: enable NSH support
Date: Tue, 26 Sep 2017 12:55:39 +0800
Message-ID: <20170926045538.GA5896@localhost.localdomain>
References: <1506348969-6233-1-git-send-email-yi.y.yang@intel.com>
 <20170925201439.08460295@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        "e@erig.me" <e@erig.me>,
        "davem@davemloft.net" <davem@davemloft.net>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:49547 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752952AbdIZE7x (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 00:59:53 -0400
Content-Disposition: inline
In-Reply-To: <20170925201439.08460295@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 26, 2017 at 02:14:39AM +0800, Jiri Benc wrote:
> On Mon, 25 Sep 2017 22:16:09 +0800, Yi Yang wrote:
> > +		return err;
> > +
> > +	key->eth.type = htons(ETH_P_NSH);
> 
> I wonder why you have this assignment here. The key is invalidated,
> thus nothing should rely on key->eth.type. However, looking at the code
> and ovs_fragment in particular, I'm not sure that's the case. Could you
> please explain why it is needed? And why the reverse of it is not
> needed in pop_nsh?

After push_nsh, the packet won't be recirculated to flow pipeline, so
key->eth.type must be set explicitly here, but for pop_nsh, the packet
will be recirculated to flow pipeline, it will be reparsed, so
key->eth.type will be set in packet parse function, we needn't handle it
in pop_nsh.

I have sent out v10 to fix all the comments for v9, please review v10,
thanks a lot.
