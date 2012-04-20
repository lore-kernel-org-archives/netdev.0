From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next 04/14] net: Fix issue with netdev_tx_reset_queue not
 resetting queue from XOFF state
Date: Fri, 20 Apr 2012 14:31:14 -0700
Message-ID: <4F91D5A2.2060300@intel.com>
References: <1331611432-30109-1-git-send-email-jeffrey.t.kirsher@intel.com> <1331611432-30109-5-git-send-email-jeffrey.t.kirsher@intel.com> <CA+mtBx-BWy=KANgSca9f2vxuu1Km_kPMJbQFa+Nq9q_YYvatBQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Tom Herbert <therbert@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:19784 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754454Ab2DTVbP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Apr 2012 17:31:15 -0400
In-Reply-To: <CA+mtBx-BWy=KANgSca9f2vxuu1Km_kPMJbQFa+Nq9q_YYvatBQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/20/2012 2:19 PM, Tom Herbert wrote:
> Hi Jeff,
> 
>> @@ -3244,7 +3246,6 @@ static void igb_clean_tx_ring(struct igb_ring *tx_ring)
>>                buffer_info = &tx_ring->tx_buffer_info[i];
>>                igb_unmap_and_free_tx_resource(tx_ring, buffer_info);
>>        }
>> -       netdev_tx_reset_queue(txring_txq(tx_ring));
>>
> Why is it necessary to remove this?  If rings are being freed with
> going through completion path then we would need this reset.  Is this
> being done elsewhere maybe?
> 

Alex moved this into the igb_configure_tx_ring() iirc to catch an ethtool
test case. He assured me when I reviewed the patch that igb_configure_tx_ring()
would always be called before netif_carrier_on() so I think(?) that should
be OK.

The above removed case was called after netif_carrier_off() anyways.

> Tom
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
