From: "Winkler, Tomas" <tomas.winkler@intel.com>
Subject: RE: [PATCH net-2.6] bridge: fix br_multicast_ipv6_rcv for paged skbs
Date: Fri, 31 Dec 2010 23:16:29 +0200
Message-ID: <6F5C1D715B2DA5498A628E6B9C124F04019BF36BBF@hasmsx504.ger.corp.intel.com>
References: <9mk4bme8o97ir27xi8a9fbsd.1293750376929@email.android.com>
 <20101231.124533.15243601.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "shemminger@vyatta.com" <shemminger@vyatta.com>,
	"johannes@sipsolutions.net" <johannes@sipsolutions.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"stephen.hemminger@vyatta.com" <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:7606 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752108Ab0LaVQz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Dec 2010 16:16:55 -0500
In-Reply-To: <20101231.124533.15243601.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Friday, December 31, 2010 10:46 PM
> To: stephen.hemminger@vyatta.com
> Cc: Winkler, Tomas; shemminger@vyatta.com; johannes@sipsolutions.net;
> netdev@vger.kernel.org; linux-wireless@vger.kernel.org
> Subject: Re: [PATCH net-2.6] bridge: fix br_multicast_ipv6_rcv for paged
> skbs
> 
> From: Stephen Hemminger <stephen.hemminger@vyatta.com>
> Date: Thu, 30 Dec 2010 15:06:16 -0800
> 
> > Although copy is slower for large packets, this is a non performance
> > path. The code in question is for bridged multicast Ipv6 ICMP
> > packets. This case is so uncritical it could be done in BASIC and no
> > one could possibly care!
> 
> I still think we should be judicious and keep using skb_clone() here.
> 
> Simply combine the two pskb_may_pull() calls into one on "skb2" after
> the clone and before the blind __skb_pull() call.  Then add a error
> path "out:" called "out_nopush:" for the error path to goto.
> 
> Also, I think the "+ 1" in the ipv6 stack code comes from the fact that
> the parsing loop can "peek" into the next header's byte to see the type.
> And I really don't think it's relevant here.
> 
> Also, all of these "x_header + ... + 1 - skb->data" factors are
> irrelevent and shouldn't be used.  Just pass "offset + sizeof(*icmp6h)"
> to pskb_may_pull().

Sounds reasonable but maybe we shall pass offset + sizeof(struct mld_msg) as *icmp6h is casted to this struct mld_mca is accessed.

struct mld_msg {
        struct icmp6hdr         mld_hdr;
        struct in6_addr         mld_mca;
};

Thanks
Tomas


---------------------------------------------------------------------
Intel Israel (74) Limited

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.

