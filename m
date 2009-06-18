From: Mike Christie <michaelc@cs.wisc.edu>
Subject: Re: [PATCH] Consolidate shared code between enic and fnic drivers.
Date: Thu, 18 Jun 2009 12:03:24 -0500
Message-ID: <4A3A735C.7090603@cs.wisc.edu>
References: <20090618050502.30610.69142.stgit@palito_client100.nuovasystems.com> <4A3A090B.9020306@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <scofeldm@cisco.com>,
	James.Bottomley@HansenPartnership.com, davem@davemloft.net,
	gospo@redhat.com, abjoglek@cisco.com, jeykholt@cisco.com,
	netdev@vger.kernel.org, linux-scsi@vger.kernel.org
To: Hannes Reinecke <hare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabe.cs.wisc.edu ([128.105.6.20]:45115 "EHLO sabe.cs.wisc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751460AbZFRRD6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jun 2009 13:03:58 -0400
In-Reply-To: <4A3A090B.9020306@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Reinecke wrote:
> Hi all,
> 
> Scott Feldman wrote:
>> Consolidate shared code between enic and fnic drivers.
>>
>> [David/James, we need a little help with this one...this single patch
>> spans scsi and netdev, so we're not sure which tree/maintainer needs
>> to pick up the patch.  Please advise.  It's for 2.6.31.  The patch is
>> against linux-2.6.git.]
>>
> Ah, finally. I was actually waiting someone would spot this ...
> 
>> The Cisco enic 10G Ethernet driver and the fnic FCoE HBA driver share
>> much of the same hardware-access code because enic and fnic devices are
>> really two functions on a converged-I/O PCIe device.  This patch
>> consolidates the shared code into one shared module, thus eliminating
>> the code duplication.  No functional changes are made by the patch.
>>
>> Why weren't these consolidated in the first place?  fnic went in late in
>> 2.6.30 on the scsi branch (merge exception for new drivers), and it was
>> too late to modify enic which was already included in 2.6.28.
>>
> Hmm. Seeing that we're getting more and more of these type of drivers
> (cf bnx2 / bnx2i / cnic, enic / fnic, and at least one other in the pipe)
> one does wonder whether we should establish a separate directory for
> these kind of things.
> drivers/virtual or drivers/shared springs to mind.
> 
> Having them in the network directory is probably not the
> correct choice.
> 

I think it might sometimes. I am not sure though. I think we have two 
models. One where this common/lib/helper/shim module requires a net 
driver/netdev and one where it does not.

I think vnic should go in a new dir. fnic does not require enic to 
interact with hardare. It only needs the vnic module and vnic module 
should not need the enic one. The fnic module does not interact with the 
  network layer's net_device.

For the second model, maybe cnic should be in the net dir. I am not 
sure. Here, bnx2i needs cnic which requires bnx2 to interact with the 
hardware. bnx2i does not directly interact with the net_device, but it 
does through the cnic/bnx2 code. cxb3/cxgb3i implements this model too.

I am fine with the second type of module going in a new dir too, but I 
just wanted to make sure everyone knows the differences between the models.
