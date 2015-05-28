From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH v4] bnx2x: Alloc 4k fragment for each rx ring buffer
 element
Date: Thu, 28 May 2015 07:24:22 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63DA8E49@avmb3.qlogic.org>
References: <553AD097.4020209@gmx.de>
	<87383jhxj9.fsf@dhcp-9-18-235-171.br.ibm.com>
	<B5657A6538887040AD3A81F1008BEC63D383CB@avmb3.qlogic.org>
	<20150430.160537.232956261880122754.davem@davemloft.net>
	<874mnsxhnm.fsf_-_@dhcp-9-18-235-171.br.ibm.com>
	<B5657A6538887040AD3A81F1008BEC63D6F990@AVMB1.qlogic.org>
 <87wq02t6ce.fsf_-_@dhcp-9-18-235-171.br.ibm.com>,<55658781.8060104@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"LinoSanfilippo@gmx.de" <LinoSanfilippo@gmx.de>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	"cascardo@cascardo.eti.br" <cascardo@cascardo.eti.br>,
	"brking@linux.vnet.ibm.com" <brking@linux.vnet.ibm.com>
To: Michal Schmidt <mschmidt@redhat.com>,
	Gabriel Krisman Bertazi <krisman@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:44519 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752733AbbE1HYh convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 03:24:37 -0400
In-Reply-To: <55658781.8060104@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +struct bnx2x_alloc_pool {
>> +     struct page     *page;
>> +     dma_addr_t      dma;
>> +     u8              offset;
>> +     u8              frag_count;
>> +};
>...
>>  static int bnx2x_alloc_rx_sge(struct bnx2x *bp, struct bnx2x_fastpath *fp,
>>                             u16 index, gfp_t gfp_mask)
>>  {
>        ...
>> +     pool->offset += SGE_PAGE_SIZE;
>> +     pool->frag_count--;
>> +
>>       return 0;
>>  }

> One SGE_PAGE_SIZE is already bigger than representable by u8, so offset
> will overflow.

Thanks for the catch Michal.

Actually, this upsets me greatly. We didn't see it on a system with 4KB
pages, but this means you've actually tried to 'sell' us a fastpath fix that
was never tested on machines for which it was meant as an improvement.

Dave - if possible, please wait with accepting any further fixes for this
issue until we [qlogic] manage to prepare a test environment
where we can properly test this with 64KB page size architecture.

Thanks,
Yuval