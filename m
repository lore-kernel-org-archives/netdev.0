From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH/RFC repost 4/8] datapath: execution of select group action
Date: Wed, 24 Sep 2014 09:19:42 +0100
Message-ID: <20140924081942.GB24298@casper.infradead.org>
References: <1411005311-11752-1-git-send-email-simon.horman@netronome.com>
 <1411005311-11752-5-git-send-email-simon.horman@netronome.com>
 <20140919140527.GB8257@casper.infradead.org>
 <20140924060107.GC13314@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	Pravin Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:38655 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754041AbaIXITn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 04:19:43 -0400
Content-Disposition: inline
In-Reply-To: <20140924060107.GC13314@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/24/14 at 03:01pm, Simon Horman wrote:
> > > +	/* Only possible type of attributes is OVS_SELECT_GROUP_ATTR_BUCKET */
> > > +	for (bucket = nla_data(attr), rem = nla_len(attr); rem > 0;
> > > +	     bucket = nla_next(bucket, &rem)) {
> > > +		uint16_t weight = bucket_weight(bucket);
> > 
> > I think we should validate only once when we copy then assume it is
> > correct.

> That is the intention of this code, is it doing something else?

I must have treated the BUG_ON as validation when I wrote that
comment ;-)

> Nice idea. I think that would work out quite well.
> 
> The main question for me would be where to store such a table,
> which comes back to my remark above about more storing a more
> efficient efficient form of the action.

I had the same issue when working on zone support for the 
conntrack action that is in the works. It needs to keep a ref to
a ct template which is registered with the conntrack engine. I
ended up converting the Netlink attributes to a struct and storing
that in an attribute in sf_acts then converting it back.

You can find the WIP code in the following branch:
https://github.com/tgraf/ovs/tree/nat

datapath: Use central function to free sw_flow_actions 
RFC: Add support for connection tracking. 
datapath: Add zone support

> > Do we need a recursion limit here?
> 
> I believe that is already handled by the depth check that occurs
> when the actions are copied.

Right, I can see it now. Thanks.
