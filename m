From: Thomas Graf <tgraf@infradead.org>
Subject: Re: [RFC V2 PATCH] rtnetlink: Fix problem with buffer allocation
Date: Wed, 15 Feb 2012 09:08:14 -0500
Message-ID: <20120215140814.GA29673@canuck.infradead.org>
References: <20120212191342.1458.70498.stgit@gitlad.jf.intel.com>
 <1329253993.2443.30.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:39240 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754406Ab2BOOIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 09:08:18 -0500
Content-Disposition: inline
In-Reply-To: <1329253993.2443.30.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 14, 2012 at 09:13:13PM +0000, Ben Hutchings wrote:
> > +		struct rtattr *ext_req;
> > +		u32 *ext_req_data;
> > +		req = (struct rtnl_req_extended *)cb->nlh;
> > +		ext_req = (struct rtattr *)&req->ext;
> > +		if (ext_req->rta_type == IFLA_EXT_MASK) {
> > +			ext_req_data = RTA_DATA(ext_req);
> > +			ext_filter_mask = *ext_req_data;
> > +		}
> > +	}
> 
> We cannot trust a flag to tell us what the length of the message is.  We
> have to check the value of nlmsg_len (which netlink has already
> validated as being within the skb length and >= our declared request
> header length).  I think that makes the flag redundant.
> 
> In fact, I think we should really use nlmsg_parse() here.  That might be
> overkill when there's only a single valid attribute; I don't know.

I think it's worth the effort. You get all the validation for free. And
please use the netlink interface in <net/netlink.h>, the rtattr based
interface has been deprecated a while ago.
