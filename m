From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [Xen-devel] xennet_start_xmit assumptions
Date: Fri, 20 Jan 2017 15:03:23 -0500
Message-ID: <20170120200323.GA30186@oracle.com>
References: <20170119.113759.555556955190770932.davem@davemloft.net>
 <20170119184733.GJ22018@oracle.com>
 <20170119224123.GB19618@oracle.com>
 <20170120.143059.1390682983473502518.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul.Durrant@citrix.com, konrad.wilk@oracle.com,
        wei.liu2@citrix.com, netdev@vger.kernel.org,
        xen-devel@lists.xenproject.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:48715 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752780AbdATUDh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 15:03:37 -0500
Content-Disposition: inline
In-Reply-To: <20170120.143059.1390682983473502518.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/20/17 14:30), David Miller wrote:
> 
> CAP_SYS_RAWIO or not, the contract we have with the device is that
> there will be at least enough bytes to cover a link layer header.

I see. If that's the case (for all the kernel-driver interfaces), 
then the xen_netfront driver is probably not required to check for
variants of sk_buffs like pure-non-linear etc.

> This probably requires a little bit of an adjustment to the calling
> convention.  Perhaps:
> 
> 	int dev_validate_header(const struct net_device *dev,
> 				char *ll_header, int len);
> 
> So then you can go:
> 
> 	new_len = dev_validate_header(dev, skb->data, len);
> 	if (new_len < 0)
> 		goto out_cleanup_err;
> 	if (new_len > len)
> 		__skb_put(skb, new_len - len);
> 
> Or something like that.

ok let me work with that and get back (hopefully with an 
RFC patch).

--Sowmini
