From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: Re: [PATCH 2/2] net: Add Keystone NetCP ethernet driver
Date: Thu, 24 Apr 2014 17:04:48 -0400
Message-ID: <53597C70.1040501@ti.com>
References: <1398201675-17379-1-git-send-email-santosh.shilimkar@ti.com>	<1398201675-17379-3-git-send-email-santosh.shilimkar@ti.com> <20140424.124744.1296959126932595844.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"Nair, Sandeep" <sandeep_n@ti.com>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:36920 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753208AbaDXVFP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2014 17:05:15 -0400
In-Reply-To: <20140424.124744.1296959126932595844.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 24 April 2014 12:47 PM, David Miller wrote:
> From: Santosh Shilimkar <santosh.shilimkar@ti.com>
> Date: Tue, 22 Apr 2014 17:21:15 -0400
> 
>> +struct netcp_tx_pipe {
>> +	struct netcp_device	*netcp_device;
>> +	void	*dma_queue;
> 
> Indent *dma_queue the same as the other struct members.
>
sure 
>> +	unsigned		dma_queue_id;
> 
> Use explicit "unsigned int".
> 
>> +	unsigned		dma_chan_id;
> 
> Likewise.
>
ok
 
>> +struct netcp_addr {
>> +	struct netcp_intf	*netcp;
>> +	unsigned char		addr[MAX_ADDR_LEN];
> 
> If this is just an ethernet driver, ETH_ALEN is more appropriate here.
> 
Yep. Will use ETH_ALEN

>> +	unsigned		tx_compl_qid;
> 
> Explicit "unsigned int" please.  I'm not going to point out all of the other
> instances, audit your entire submission for this problem please.
>
Thats true... Will fix all instances of those. 

 
>> +static inline u32 *netcp_push_psdata(struct netcp_packet *p_info,
>> +				     unsigned bytes)
>> +{
>> +	u32		*buf;
>> +	unsigned	 words;
> 
> Do not use tabs between the type and the variable name in local variable
> declarations.
> 
ok

> Please audit for and fix this in your entire submission.
>
Will Do.
 
>> +static inline u32 hwval_to_host(bool big_endian, u32 hwval)
>> +{
>> +	if (big_endian)
>> +		return be32_to_cpu(hwval);
>> +	else
>> +		return le32_to_cpu(hwval);
>> +}
> 
> You're much better off having a set of methods, one for big endian and
> one for little endian, that just straight line codes the appropriate endian
> accesses.
>
good idea.
 
> These conditionals peppered all over the place are just ugly.
> 
Agree. Will try to fit into some logical functions.

Thanks for the review David !!

regards,
Santosh
