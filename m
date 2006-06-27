From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 02/21] e1000: rework driver hardware reset locking
Date: Tue, 27 Jun 2006 07:42:59 -0700
Message-ID: <44A143F3.1050604@intel.com>
References: <20060622051815.25497.89192.stgit@gitlost.site> <20060622052009.25497.46358.stgit@gitlost.site> <44A08CEC.1080108@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:3351 "EHLO
	azsmga101-1.ch.intel.com") by vger.kernel.org with ESMTP
	id S1030200AbWF0OnE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 10:43:04 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <44A08CEC.1080108@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Kok, Auke wrote:
>> @@ -631,6 +627,9 @@ e1000_set_ringparam(struct net_device *n
>>      tx_ring_size = sizeof(struct e1000_tx_ring) * 
>> adapter->num_tx_queues;
>>      rx_ring_size = sizeof(struct e1000_rx_ring) * 
>> adapter->num_rx_queues;
>>  
>> +    while (test_and_set_bit(__E1000_RESETTING, &adapter->flags))
>> +        msleep(1);
> 
> This is a bit worrying, but no outright objection.  We don't want to see 
> these accumulate.

Agreed but at least we removed the opportunity to panic the driver as easy as 
with 2 commandline commands (in several ways) - we're still looking into 
improving this - any comments would be appreciated.

Cheers,

Auke
