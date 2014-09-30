From: David Miller <davem@davemloft.net>
Subject: Re: How exactly does CHECKSUM_COMPLETE works?
Date: Tue, 30 Sep 2014 14:48:19 -0400 (EDT)
Message-ID: <20140930.144819.890888642079982128.davem@davemloft.net>
References: <B5657A6538887040AD3A81F1008BEC63B41317@avmb3.qlogic.org>
	<CA+mtBx_17aJuK=xjnDukGJOfw-twHg=rF5rDacg6pga6ZTTRcw@mail.gmail.com>
	<CAADnVQLxX4LGFfqd6x+krfEMB57y_o80xW_3brkPvEJueDNWVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, Yuval.Mintz@qlogic.com, netdev@vger.kernel.org
To: alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48269 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751408AbaI3SsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 14:48:24 -0400
In-Reply-To: <CAADnVQLxX4LGFfqd6x+krfEMB57y_o80xW_3brkPvEJueDNWVg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Tue, 30 Sep 2014 09:58:32 -0700

> On Tue, Sep 30, 2014 at 7:59 AM, Tom Herbert <therbert@google.com> wrote:
>>
>>> So, to summarize my questions -
>>> 1. What should a driver set as the SKBs csum value when passing CHECKSUM_COMPLETE?
>>
>> This ones complete checksum of the Ethernet payload (start of IP
>> header to the end of the packet).
> 
> I think it's confusing to describe CHECKSUM_COMPLETE this way.
> It is such only because driver pulls eth header before passing skb to stack.
> CHECKSUM_COMPLETE should cover the whole packet. If there are multiple
> vlan headers in front of IP they should be part of csum, since not all
> drivers may
> have hw offloading for vlan. The most simplistic HW would compute csum over
> the whole packet including eth header and driver will do
> eth_type_trans+skb_postpull_rcsum

The sungem computes the checksum over the entire frame.  Here are the relevant
parts from the programmer's manual:

	RX Descriptor Fields
  ...
	TCP Pseudo-Checksum - Contains the 16-bit TCP checksum calculated over
	the entire frame, starting at an offset programmable in the RX
	Configuration Register.

In the gengem driver this is the RXDMA_CFG_CSUMOFF field of the RXDMA_CFG
register.

The driver seems to set this to the size of the ethernet header, which has
the problems you mention.
