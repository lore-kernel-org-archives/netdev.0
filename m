From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next-2.6 PATCH v2 1/4] dcbnl: adding DCBX engine capability
Date: Thu, 30 Dec 2010 11:09:20 -0800
Message-ID: <4D1CD8E0.80202@intel.com>
References: <1293726408.29378.92.camel@lb-tlvb-shmulik.il.broadcom.com> <4D1CD560.3000609@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Eilon Greenstein <eilong@broadcom.com>,
	"Liu, Lucy" <lucy.liu@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Shmulik Ravid <shmulikr@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:51838 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754966Ab0L3TJp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Dec 2010 14:09:45 -0500
In-Reply-To: <4D1CD560.3000609@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/30/2010 10:54 AM, John Fastabend wrote:
> On 12/30/2010 8:26 AM, Shmulik Ravid wrote:
>> Adding an optional DCBX capability and a pair for get-set routines for
>> setting the device DCBX mode. The DCBX capability is a bit field of
>> supported attributes. The user is expected to set the DCBX mode with a
>> subset of the advertised attributes.
>>
>> This patch is dependent on the following patches:
>> [net-next-2.6 PATCH 1/3] dcbnl: add support for ieee8021Qaz attributes
>> [net-next-2.6 PATCH 2/3] dcbnl: add appliction tlv handlers
>> [net-next-2.6 PATCH 3/3] net_dcb: add application notifiers
>>
>> Signed-off-by: Shmulik Ravid <shmulikr@broadcom.com>
>> ---
> 
> Acked-by: John Fastabend <john.r.fastabend@intel.com>
> 
> Thanks for doing this Shmulik.
> 

Sorry missed this on my first pass.

>  
> +/* DCBX configuration */
> +static int dcbnl_getdcbx(struct net_device *netdev, struct nlattr **tb,
> +			 u32 pid, u32 seq, u16 flags)
> +{
> +	int ret = -EINVAL;
> +
> +	if (!netdev->dcbnl_ops->getdcbx)
> +		return ret;

I think we should actually return -EOPNOTSUPP here.

> +
> +	ret = dcbnl_reply(netdev->dcbnl_ops->getdcbx(netdev), RTM_GETDCB,
> +			  DCB_CMD_GDCBX, DCB_ATTR_DCBX, pid, seq, flags);
> +
> +	return ret;
> +}
> +
