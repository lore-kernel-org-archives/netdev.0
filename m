From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next-2.6 PATCH v2 2/4] dcbnl: adding DCBX feature flags
 get-set
Date: Thu, 30 Dec 2010 11:05:56 -0800
Message-ID: <4D1CD814.2010903@intel.com>
References: <1293726415.29378.93.camel@lb-tlvb-shmulik.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Eilon Greenstein <eilong@broadcom.com>,
	"Liu, Lucy" <lucy.liu@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Shmulik Ravid <shmulikr@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:22764 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754961Ab0L3TF6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Dec 2010 14:05:58 -0500
In-Reply-To: <1293726415.29378.93.camel@lb-tlvb-shmulik.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/30/2010 8:26 AM, Shmulik Ravid wrote:
> Adding a pair of set-get routines to dcbnl for setting the negotiation
> flags of the various DCB features. Conforms to the CEE flavor of DCBX
> The user sets these flags (enable, advertise, willing) for each feature
> to be used by the DCBX engine. The 'get' routine returns which of the
> features is enabled after the negotiation.
> 
> This patch is dependent on the following patches:
> [net-next-2.6 PATCH 1/3] dcbnl: add support for ieee8021Qaz attributes
> [net-next-2.6 PATCH 2/3] dcbnl: add appliction tlv handlers
> [net-next-2.6 PATCH 3/3] net_dcb: add application notifiers
> 
> Signed-off-by: Shmulik Ravid <shmulikr@broadcom.com>
> ---

[...]

One more nit ;)

> +
> +	ret = nla_parse_nested(data, DCB_FEATCFG_ATTR_MAX, tb[DCB_ATTR_FEATCFG],
> +			       dcbnl_featcfg_nest);
> +	if (ret) {
> +		ret = -EINVAL;
> +		goto err_out;
> +	}

Why do you set EINVAL here if you use the returned error code from nla_parse_nested you get a more descriptive error. See ./lib/nlattr.c:nla_parse()/validate_nla().

[...]

> +static int dcbnl_setfeatcfg(struct net_device *netdev, struct nlattr **tb,
> +			    u32 pid, u32 seq, u16 flags)
> +{
> +	struct nlattr *data[DCB_FEATCFG_ATTR_MAX + 1];
> +	int ret = -EINVAL;
> +	u8 value;
> +	int i;
> +
> +	if (!tb[DCB_ATTR_FEATCFG] || !netdev->dcbnl_ops->setfeatcfg)
> +		return ret;
> +
> +	ret = nla_parse_nested(data, DCB_FEATCFG_ATTR_MAX, tb[DCB_ATTR_FEATCFG],
> +			       dcbnl_featcfg_nest);
> +
> +	if (ret) {
> +		ret = -EINVAL;
> +		goto err;
> +	}

Same here.

Thanks,
John.
