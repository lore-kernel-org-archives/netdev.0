From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: Re: [PATCH 6/13] forcedeth: add/modify tx done with limit
Date: Tue, 10 Mar 2009 06:17:52 -0500
Message-ID: <49B64C60.9080903@nvidia.com>
References: <49B013A2.8030806@nvidia.com> <20090310.053212.39968484.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "manfred@colorfullife.com" <manfred@colorfullife.com>,
	"jgarzik@pobox.com" <jgarzik@pobox.com>,
	"akpm@osdl.org" <akpm@osdl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:7737 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754631AbZCJRz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 13:55:57 -0400
In-Reply-To: <20090310.053212.39968484.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



David Miller wrote:
> From: Ayaz Abdulla <aabdulla@nvidia.com>
> Date: Thu, 05 Mar 2009 13:02:10 -0500
> 
> 
>>There are two tx_done routines to handle tx completion processing. Both these functions now take in a limit value and return the amount of tx completions. This will be used by a future patch to determine the total amount of work done.
>>
>>Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>
> 
> 
> Applied.
> 
> But I would absolutely not count TX completion processing in the
> NAPI work limit as you do in one of the subsequent patches.
> 

I agree. However, I am counting tx work only for the purpose of 
interrupt moderation.  The tx work count is not included in the NAPI 
limit check.
ie.

+	nv_change_interrupt_mode(dev, tx_work + rx_work);

-	if (pkts < budget) {
+	if (rx_work < budget) {


> TX completely is just buffer freeing, very cheap.
> 
> Whereas RX processing involves actually network stack processing
> which is real work and is what NAPI should be limiting.
> 
> Also, please get rid of the NAPI config option for this driver and
> make NAPI unconditionally enabled.
> 

Sure, I will submit a new patch for removing the config option.

> Thanks.

-----------------------------------------------------------------------------------
This email message is for the sole use of the intended recipient(s) and may contain
confidential information.  Any unauthorized review, use, disclosure or distribution
is prohibited.  If you are not the intended recipient, please contact the sender by
reply email and destroy all copies of the original message.
-----------------------------------------------------------------------------------
