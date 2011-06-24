From: Scott Goldman <scottjg@vmware.com>
Subject: RE: [Pv-drivers] [PATCH] vmxnet3: Enable GRO support.
Date: Fri, 24 Jun 2011 15:02:04 -0700
Message-ID: <03E840D17E263A48A5766AD576E0423A0129262BB5@exch-mbx-111.vmware.com>
References: <1308947605-4300-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: VMware PV-Drivers <pv-drivers@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>, David Miller <davem@davemloft.net>,
	Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:45186 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755479Ab1FXWCF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jun 2011 18:02:05 -0400
In-Reply-To: <1308947605-4300-1-git-send-email-jesse@nicira.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jesse.

 
> When receiving packets from another guest on the same hypervisor, it's
> generally possible to receive large packets because no segmentation is
> necessary and these packets are handled by LRO.  However, when doing
> routing or bridging we must disable LRO and lose this benefit.  In
> these cases GRO can still be used and it is very effective because the
> packets which are segmented in the hypervisor are received very close
> together and can easily be merged.


> -			netif_receive_skb(skb);
> +			napi_gro_receive(&rq->napi, skb);

So... this doesn't discriminate between if LRO is off or on.  The last time I tried using GRO on top of our hardware LRO, there was actually some minor performance penalty. Do you have any benchmarks showing that this is ok? If not, do you think it might make sense to just do gro only if(unlikely(lro is off))?

Thanks,
-sjg
