From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCHv9 net-next 2/4] sunvnet: make transmit path zero-copy
 in the kernel
Date: Thu, 02 Oct 2014 07:11:00 -0400
Message-ID: <542D32C4.8070703@oracle.com>
References: <5429EFBB.2090909@oracle.com> <77E6695E-58F8-4D10-8ED7-EEC4A487339E@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:39380 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752254AbaJBLLH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 07:11:07 -0400
In-Reply-To: <77E6695E-58F8-4D10-8ED7-EEC4A487339E@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/02/2014 01:50 AM, Raghuram Kothakota wrote:


>> +	err = ldc_map_single(port->vio.lp, start, nlen,
>> +			     port->tx_bufs[txi].cookies, 2,
>> +			     (LDC_MAP_SHADOW | LDC_MAP_DIRECT | LDC_MAP_RW));
> 
> 
> The LDC sharing protection mechanism is at a page level. If I understand
> well, the vnet_skb_shape() function only addresses the alignment requirement
> but it still leaves the possibility of exporting a lot more data than required to the
> peer. This can be treated as a security issue,  wondering if you thought of this issue.

Since the specific offsets and lengths are provided in the API, I didn't realize that it was
sharing more than the provided buffer until you pointed that out, before I submitted the
patches. At that point, I considered it.

The original buffers were ~1500 byte kzalloc'ed (for each buffer), meaning that they were
potentially shared with arbitrary kernel memory on the same page.

This patch-set doesn't increase or decrease any security concerns related to oversharing
with other LDOMs. The extents outside the provided buffers are (now) skbs, and so packet
data, where before they could be any dynamically allocated kernel memory.

								+-DLS
