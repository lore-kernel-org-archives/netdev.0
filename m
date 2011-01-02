From: "Shmulik Ravid" <shmulikr@broadcom.com>
Subject: Re: [net-next-2.6 PATCH v2 2/4] dcbnl: adding DCBX feature
 flags get-set
Date: Sun, 2 Jan 2011 18:01:01 +0200
Message-ID: <1293984061.29378.101.camel@lb-tlvb-shmulik.il.broadcom.com>
References: <1293726415.29378.93.camel@lb-tlvb-shmulik.il.broadcom.com>
 <4D1CD814.2010903@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Liu, Lucy" <lucy.liu@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "John Fastabend" <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3851 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751339Ab1ABQBS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Jan 2011 11:01:18 -0500
In-Reply-To: <4D1CD814.2010903@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> One more nit ;)
> 
> > +
> > +	ret = nla_parse_nested(data, DCB_FEATCFG_ATTR_MAX, tb[DCB_ATTR_FEATCFG],
> > +			       dcbnl_featcfg_nest);
> > +	if (ret) {
> > +		ret = -EINVAL;
> > +		goto err_out;
> > +	}
> 
> Why do you set EINVAL here if you use the returned error code from nla_parse_nested you get a more descriptive error. See ./lib/nlattr.c:nla_parse()/validate_nla().
> 
> [...]
> 
> > +static int dcbnl_setfeatcfg(struct net_device *netdev, struct nlattr **tb,
> > +			    u32 pid, u32 seq, u16 flags)
> > +{
> > +	struct nlattr *data[DCB_FEATCFG_ATTR_MAX + 1];
> > +	int ret = -EINVAL;
> > +	u8 value;
> > +	int i;
> > +
> > +	if (!tb[DCB_ATTR_FEATCFG] || !netdev->dcbnl_ops->setfeatcfg)
> > +		return ret;
> > +
> > +	ret = nla_parse_nested(data, DCB_FEATCFG_ATTR_MAX, tb[DCB_ATTR_FEATCFG],
> > +			       dcbnl_featcfg_nest);
> > +
> > +	if (ret) {
> > +		ret = -EINVAL;
> > +		goto err;
> > +	}
> 
> Same here.
> 

I'll send a patch with the improved return values for the the new dcbnl
routines. While I'm at it, is it safe to fix on the same lines the
older already established dcbnl routines?

Thanks,
Shmulik



