From: Brian King <brking@linux.vnet.ibm.com>
Subject: Re: [PATCH] mlx4_en: map entire pages to increase throughput
Date: Tue, 17 Jul 2012 15:10:08 -0500
Message-ID: <5005C6A0.50002@linux.vnet.ibm.com>
References: <1342458113-10384-1-git-send-email-cascardo@linux.vnet.ibm.com> <50044F1D.6000703@hp.com> <20120716.222903.367603216293954363.davem@davemloft.net> <5005AC4A.9030208@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"cascardo@linux.vnet.ibm.com" <cascardo@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"yevgenyp@mellanox.co.il" <yevgenyp@mellanox.co.il>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"amirv@mellanox.com" <amirv@mellanox.com>,
	"leitao@linux.vnet.ibm.com" <leitao@linux.vnet.ibm.com>,
	"klebers@linux.vnet.ibm.com" <klebers@linux.vnet.ibm.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:57103 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754813Ab2GQUL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 16:11:26 -0400
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <brking@linux.vnet.ibm.com>;
	Tue, 17 Jul 2012 14:11:25 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 2D95C19D8048
	for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 20:10:23 +0000 (WET)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6HKAD7Y276402
	for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 14:10:14 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6HKA9mB007564
	for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 14:10:13 -0600
In-Reply-To: <5005AC4A.9030208@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/17/2012 01:17 PM, Rick Jones wrote:
> On 07/16/2012 10:29 PM, David Miller wrote:
>> From: Rick Jones <rick.jones2@hp.com> Date: Mon, 16 Jul 2012
>> 10:27:57 -0700
>> 
>>> That seems rather extraordinarily low - Power7 is supposed to be
>>> a rather high performance CPU.  The last time I noticed
>>> O(3Gbit/s) on 10G for bulk transfer was before the advent of
>>> LRO/GRO - that was in the x86 space though.  Is mapping really
>>> that expensive with Power7?
>> 
>> Unfortunately, IOMMU mappings are incredibly expensive.  I see
>> effects like this on Sparc too.
> 
> OK, so that has caused some dimm memory to get a small refresh - it
> ends up being akin to if not actually a PIO yes?  I recall schemes in
> drivers in other stacks whereby "small" packets were copied because
> it was cheaper to allocate/copy then it was to remap.

On Power it ends up being an hcall to the hypervisor

-Brian

-- 
Brian King
Power Linux I/O
IBM Linux Technology Center
