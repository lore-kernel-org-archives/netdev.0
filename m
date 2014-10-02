From: Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
Subject: Re: [PATCHv9 net-next 2/4] sunvnet: make transmit path zero-copy in the kernel
Date: Thu, 2 Oct 2014 16:11:42 -0700
Message-ID: <83C35E69-1059-4245-BE4C-B1CB6CB3EA93@oracle.com>
References: <5429EFBB.2090909@oracle.com> <77E6695E-58F8-4D10-8ED7-EEC4A487339E@oracle.com> <542D32C4.8070703@oracle.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: David L Stevens <david.stevens@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:48069 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753658AbaJBXLs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 19:11:48 -0400
In-Reply-To: <542D32C4.8070703@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Oct 2, 2014, at 4:11 AM, David L Stevens <david.stevens@oracle.com> wrote:

> 
> 
> On 10/02/2014 01:50 AM, Raghuram Kothakota wrote:
> 
> 
>>> +	err = ldc_map_single(port->vio.lp, start, nlen,
>>> +			     port->tx_bufs[txi].cookies, 2,
>>> +			     (LDC_MAP_SHADOW | LDC_MAP_DIRECT | LDC_MAP_RW));
>> 
>> 
>> The LDC sharing protection mechanism is at a page level. If I understand
>> well, the vnet_skb_shape() function only addresses the alignment requirement
>> but it still leaves the possibility of exporting a lot more data than required to the
>> peer. This can be treated as a security issue,  wondering if you thought of this issue.
> 
> Since the specific offsets and lengths are provided in the API, I didn't realize that it was
> sharing more than the provided buffer until you pointed that out, before I submitted the
> patches. At that point, I considered it.
> 
> The original buffers were ~1500 byte kzalloc'ed (for each buffer), meaning that they were
> potentially shared with arbitrary kernel memory on the same page.

That is not good as well, we do not want to share more than what the other guest
need to see.

-Raghuram
> 
> This patch-set doesn't increase or decrease any security concerns related to oversharing
> with other LDOMs. The extents outside the provided buffers are (now) skbs, and so packet
> data, where before they could be any dynamically allocated kernel memory.
> 
> 								+-DLS
