From: Jan Scheurich <jan.scheurich@ericsson.com>
Subject: RE: [PATCH net-next v7] openvswitch: enable NSH support
Date: Mon, 4 Sep 2017 14:07:45 +0000
Message-ID: <CFF8EF42F1132E4CBE2BF0AB6C21C58D787F4EEB@ESESSMB107.ericsson.se>
References: <1504096752-102003-1-git-send-email-yi.y.yang@intel.com>
        <20170831124516.0c5db686@griffin>
        <20170904080005.GA70767@cran64.bj.intel.com>
        <20170904124216.6db68e8c@griffin>
        <CFF8EF42F1132E4CBE2BF0AB6C21C58D787F4E84@ESESSMB107.ericsson.se>
 <20170904151601.2f198a53@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Yang, Yi" <yi.y.yang@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        "e@erig.me" <e@erig.me>, "blp@ovn.org" <blp@ovn.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:59049 "EHLO
        sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753866AbdIDOHr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2017 10:07:47 -0400
In-Reply-To: <20170904151601.2f198a53@griffin>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > So is what you are suggesting the following?
> >
> > For matching:
> > OVS_KEY_ATTR_NSH_BASE_HEADER		mandatory
> > OVS_KEY_ATTR_NSH_MD1_CONTEXT		optional, in case MDTYPE == MD1
> 
> This needs to be:
> 
> OVS_KEY_ATTR_NSH
> 	OVS_KEY_ATTR_NSH_BASE_HEADER
> 	OVS_KEY_ATTR_NSH_MD1_CONTEXT
> 
> > For setting:
> > OVS_ACTION_ATTR_SET_MASKED
> > -    OVS_KEY_ATTR_NSH_BASE_HEADER		when setting any base header fields
> > OVS_ACTION_ATTR_SET_MASKED
> > -    OVS_KEY_ATTR_NSH_MD1_CONTEXT	when setting any MD1 context data fields
> 
> This needs to be:
> 
> OVS_ACTION_ATTR_SET_MASKED
> 	OVS_KEY_ATTR_NSH
> 		OVS_KEY_ATTR_NSH_BASE_HEADER
> 		OVS_KEY_ATTR_NSH_MD1_CONTEXT
> 

Then perhaps I misunderstood your comment. I thought you didn't like that the 
SET_MASKED action wrapped OVS_KEY_ATTR_NSH which in itself was nested.
I was aiming to avoid this by lifting the two components of the NSH header 
components to the top level:
OVS_NSH_ATTR_BASE_HEADER --> OVS_KEY_ATTR_NSH_BASE_HEADER
OVS_NSH_ATTR_MD1_CONTEXT --> OVS_KEY_ATTR_NSH_MD1_CONTEXT

> In your example, there's no way to distinguish OVS_KEY_ATTR_ENCAP and
> OVS_KEY_ATTR_NSH_BASE_HEADER, they are both "1".

See above. The two would be separate values in the same enum, i.e. distinct.

> > Should we consider to stick to that simple and efficient approach? As far
> > As I can see it will be generic for the foreseeable future.
> 
> I'm not sure. From the kernel point of view, we want the same
> functionality offered by the openvswitch module and by a tc action.
> 
> In theory, it can be the tc tool that constructs the header from the
> command line but there's no precedent. Dunno.

Not sure I have the full picture here. Are you saying that the tc tool uses the same
Netlink API to the kernel as OVS? What would be the back-end for tc? Also the
openvswitch kernel module? 

BR, Jan
