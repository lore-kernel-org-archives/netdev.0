From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 3/3] e1000e: fix EEH recovery during reset on PPC
Date: Thu, 26 Jun 2008 22:52:24 -0700
Message-ID: <9929d2390806262252k54071ab5tbb8e515e23ff68c3@mail.gmail.com>
References: <20080625000036.16592.6621.stgit@localhost.localdomain>
	 <20080625000120.16592.89100.stgit@localhost.localdomain>
	 <486472F1.4050900@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, pl@us.ibm.com
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.235]:20543 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758914AbYF0Fw3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 01:52:29 -0400
Received: by rv-out-0506.google.com with SMTP id k40so399075rvb.1
        for <netdev@vger.kernel.org>; Thu, 26 Jun 2008 22:52:24 -0700 (PDT)
In-Reply-To: <486472F1.4050900@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 26, 2008 at 9:56 PM, Jeff Garzik <jeff@garzik.org> wrote:
> Jeff Kirsher wrote:
>>
>> EEH is not recovering in a reasonable amount of time on PPC during
>> e1000e_down().
>>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>> ---
>>
>>  drivers/net/e1000e/netdev.c |    3 ++-
>>  1 files changed, 2 insertions(+), 1 deletions(-)
>>
>> diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
>> index ccb8ca2..0320925 100644
>> --- a/drivers/net/e1000e/netdev.c
>> +++ b/drivers/net/e1000e/netdev.c
>> @@ -2535,7 +2535,8 @@ void e1000e_down(struct e1000_adapter *adapter)
>>        adapter->link_speed = 0;
>>        adapter->link_duplex = 0;
>>  -       e1000e_reset(adapter);
>> +       if (!pci_channel_offline(adapter->pdev))
>> +               e1000e_reset(adapter);
>>        e1000_clean_tx_ring(adapter);
>>        e1000_clean_rx_ring(adapter);
>
> IMO for this type of change, you should consider putting all these changes
> into a single patch.
>
> It's exactly the same logical change, so no need to split it up into three
> patches.
>

Ok, thank.  I will keep that in mind for future patches.

-- 
Cheers,
Jeff
