From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH v2 08/13] net: ethernet: ti: cpts: move dt props parsing
 to cpts driver
Date: Tue, 29 Nov 2016 09:54:26 -0600
Message-ID: <b4503f15-6927-9b09-7cb0-ce1c8a8c4f59@ti.com>
References: <20161128230337.6731-1-grygorii.strashko@ti.com>
 <20161128230337.6731-9-grygorii.strashko@ti.com>
 <20161129101112.GG3110@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>,
        <devicetree@vger.kernel.org>,
        Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lelnx193.ext.ti.com ([198.47.27.77]:13473 "EHLO
        lelnx193.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756324AbcK2Pya (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 10:54:30 -0500
In-Reply-To: <20161129101112.GG3110@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 11/29/2016 04:11 AM, Richard Cochran wrote:
> On Mon, Nov 28, 2016 at 05:03:32PM -0600, Grygorii Strashko wrote:
>> +static int cpts_of_parse(struct cpts *cpts, struct device_node *node)
>> +{
>> +	int ret = -EINVAL;
>> +	u32 prop;
>> +
>> +	if (of_property_read_u32(node, "cpts_clock_mult", &prop))
>> +		goto  of_error;
>> +	cpts->cc_mult = prop;
> 
> Why not set cc.mult here at the same time?

The same reason as in prev patch - cpts->cc_mult is original/initial mult
value loaded from DT (or calculated), while cc.mult is dynamic value
which can be changed as part of freq adjustment.

> 
>> +
>> +	if (of_property_read_u32(node, "cpts_clock_shift", &prop))
>> +		goto  of_error;
>> +	cpts->cc.shift = prop;
>> +
>> +	return 0;
>> +
>> +of_error:
>> +	dev_err(cpts->dev, "CPTS: Missing property in the DT.\n");
>> +	return ret;
>> +}
> 


-- 
regards,
-grygorii
