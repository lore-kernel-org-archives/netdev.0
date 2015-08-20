From: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Subject: Re: [RFC v3 1/3] iwlwifi: mvm: add real TSO implementation
Date: Thu, 20 Aug 2015 13:27:48 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB32E8264A2@hasmsx107.ger.corp.intel.com>
References: <1440058544-20342-1-git-send-email-emmanuel.grumbach@intel.com>
	 <1440058544-20342-2-git-send-email-emmanuel.grumbach@intel.com>
 <1440076363.6610.40.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"Sharon, Sara" <sara.sharon@intel.com>,
	"ido@wizery.com" <ido@wizery.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:46334 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752447AbbHTN14 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 09:27:56 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/20/2015 04:13 PM, Eric Dumazet wrote:
> On Thu, 2015-08-20 at 11:15 +0300, Emmanuel Grumbach wrote:
>> The segmentation is done completely in software. The
>> driver creates several MPDUs out of a single large send.
>> Each MPDU is a newly allocated SKB.
>> A page is allocated to create the headers that need to be
>> duplicated (SNAP / IP / TCP). The WiFi header is in the
>> header of the newly created SKBs.
>>
>> type=feature
>>
>> Change-Id: I238ffa79cacc5bbdacdfbf3e9673c8d4f02b462a
>> Signed-off-by: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
>> ---
>>  drivers/net/wireless/iwlwifi/mvm/tx.c | 513 +++++++++++++++++++++++++++++++---
>>  1 file changed, 481 insertions(+), 32 deletions(-)
> 
> 
> Ouch again.
> 
> This will be a NACK. Sorry.
> 
> 

To be honest, I don't see why. No matter how you look at it, you need to
add headers. And these headers need to sit on some memory that is not
yet allocated. skb_gso_segment allocates new skb which is a memory
allocation.

I looked at ethernet/marvell/mvneta.c (which uses net/core/tso.c) and
they pre-allocate DMA coherent memory for the additional headers they
create. I can have pre-allocated pages if you want.
