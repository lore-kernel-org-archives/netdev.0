From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: Re: [PATCH net-next] net: ena: Add a driver for Amazon Elastic
 Network Adapters (ENA)
Date: Tue, 21 Jun 2016 13:02:24 +0300
Message-ID: <0ab8380b-e9f1-7137-586c-9a4ab7f39da1@annapurnalabs.com>
References: <1465807573-11293-1-git-send-email-netanel@annapurnalabs.com>
 <20160617211118.GA14822@electric-eye.fr.zoreil.com>
 <ff2fbee5-46c1-15a8-d283-4320e122934a@annapurnalabs.com>
 <20160620224316.GA11834@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, zorik@annapurnalabs.com,
	saeed@annapurnalabs.com, alex@annapurnalabs.com, msw@amazon.com,
	aligouri@amazon.com, antoine.tenart@free-electrons.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:36186 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751590AbcFUKC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 06:02:29 -0400
Received: by mail-lb0-f182.google.com with SMTP id ak10so7284560lbc.3
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 03:02:28 -0700 (PDT)
In-Reply-To: <20160620224316.GA11834@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 06/21/2016 01:43 AM, Francois Romieu wrote:
> Netanel Belgazal <netanel@annapurnalabs.com> :
> [...]
>>> diff --git a/drivers/net/ethernet/amazon/ena/ena_com.h b/drivers/net/ethernet/amazon/ena/ena_com.h
>>> new file mode 100644
>>> index 0000000..e49ba43
>>> --- /dev/null
>>> [...]
>>> +static inline void ena_com_update_intr_reg(struct ena_eth_io_intr_reg *intr_reg,
>>> +					   u32 rx_delay_interval,
>>> +					   u32 tx_delay_interval,
>>> +					   bool unmask)
>>> +{
>>> +	intr_reg->intr_control = 0;
>>> +	intr_reg->intr_control |= rx_delay_interval &
>>> +		ENA_ETH_IO_INTR_REG_RX_INTR_DELAY_MASK;
>>> +
>>> +	intr_reg->intr_control |=
>>> +		(tx_delay_interval << ENA_ETH_IO_INTR_REG_TX_INTR_DELAY_SHIFT)
>>> +		& ENA_ETH_IO_INTR_REG_RX_INTR_DELAY_MASK;
>>>                                       ^^ TX ?
>>>
>>> Extra: you should not return NETDEV_TX_BUSY in the xmit handler while
>>> queueing is still enabled. Please drop packet and return NETDEV_TX_OK.
>> Ack.
>>
>> Thanks for your review.
> Ack/nack regarding use of ..._RX_INTR_DELAY_MASK with ..._TX_INTR_DELAY_SHIFT ?
You are right, it should have been TX_INTR_DELAY_SHIFT.
I'll fix that.
