From: Mike Christie <michaelc@cs.wisc.edu>
Subject: Re: [PANIC] lro + iscsi or lro + skb text search causes panic
Date: Thu, 22 Jan 2009 22:29:35 -0600
Message-ID: <497947AF.9030901@cs.wisc.edu>
References: <alpine.WNT.2.00.0901221234420.4188@jbrandeb-desk1.amr.corp.intel.com> <4978F804.3060502@cs.wisc.edu> <49794612.9010204@cs.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, olaf.kirch@oracle.com, tgraf@suug.ch,
	kkeil@suse.de, herbert@gondor.apana.org.au
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabe.cs.wisc.edu ([128.105.6.20]:54359 "EHLO sabe.cs.wisc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754745AbZAWEax (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2009 23:30:53 -0500
In-Reply-To: <49794612.9010204@cs.wisc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mike Christie wrote:
> Mike Christie wrote:
>> Brandeburg, Jesse wrote:
>>>
>>> skb_copy_bits is an example of the code flow that does work.
>>>
>>> skb_seq_read appears to only be used by iSCSI and the skb text match 
>>> support in tc/netfilter (aka skb_find_text)
>>>
>>
>> There is no reason iscsi needs to use skb_seq_read. It used to use 
>> skb_copy_bits. I can convert iscsi to use skb_copy_bits again.
>>
> 
> Attached is a patch made against the scsi maintainer's tree (I think it 
> should also apply to linus's) that converts iscsi to use skb_copy_bits. 
> It is lightly tested. If there is no benefit in having skb_find_text use 
> skb_seq_read maybe we can just kill it, so people do not have to 
> maintain two helpers that provide similar functionality.
> 

There is a bug in this patch, but it just makes it a little less 
efficient. It should not screw up testing to verify that the oops is fixed.
