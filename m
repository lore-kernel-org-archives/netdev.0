From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC V2 PATCH] rtnetlink: Fix problem with buffer allocation
Date: Wed, 15 Feb 2012 16:32:01 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A0702F8D2A9@ORSMSX106.amr.corp.intel.com>
References: <20120212191342.1458.70498.stgit@gitlad.jf.intel.com>
 <1329253993.2443.30.camel@bwh-desktop>
 <20120215140814.GA29673@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Thomas Graf <tgraf@infradead.org>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:63018 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752054Ab2BOQb5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 11:31:57 -0500
In-Reply-To: <20120215140814.GA29673@canuck.infradead.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Thomas Graf [mailto:tgr@infradead.org] On Behalf Of Thomas Graf
> Sent: Wednesday, February 15, 2012 6:08 AM
> To: Ben Hutchings
> Cc: Rose, Gregory V; netdev@vger.kernel.org; davem@davemloft.net
> Subject: Re: [RFC V2 PATCH] rtnetlink: Fix problem with buffer allocation
> 
> On Tue, Feb 14, 2012 at 09:13:13PM +0000, Ben Hutchings wrote:
> > > +		struct rtattr *ext_req;
> > > +		u32 *ext_req_data;
> > > +		req = (struct rtnl_req_extended *)cb->nlh;
> > > +		ext_req = (struct rtattr *)&req->ext;
> > > +		if (ext_req->rta_type == IFLA_EXT_MASK) {
> > > +			ext_req_data = RTA_DATA(ext_req);
> > > +			ext_filter_mask = *ext_req_data;
> > > +		}
> > > +	}
> >
> > We cannot trust a flag to tell us what the length of the message is.  We
> > have to check the value of nlmsg_len (which netlink has already
> > validated as being within the skb length and >= our declared request
> > header length).  I think that makes the flag redundant.
> >
> > In fact, I think we should really use nlmsg_parse() here.  That might be
> > overkill when there's only a single valid attribute; I don't know.
> 
> I think it's worth the effort. You get all the validation for free. And
> please use the netlink interface in <net/netlink.h>, the rtattr based
> interface has been deprecated a while ago.

Yes, I'm changing it to use nlmsg_parse.  Didn't know about the deprecation of rtattr though, thanks for the tip.

- Greg
