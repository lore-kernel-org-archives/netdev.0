From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] udptunnel: Add SKB_GSO_UDP_TUNNEL during
 gro_complete.
Date: Mon, 10 Nov 2014 14:33:48 -0500 (EST)
Message-ID: <20141110.143348.968744105996557913.davem@davemloft.net>
References: <1415391969-108511-1-git-send-email-jesse@nicira.com>
	<28743.1415411491@famine>
	<CAEP_g=9Z4_xOnPJDcxGgSPvw1Heu5FGrij_L5Xbi6FeFfAwLvQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jay.vosburgh@canonical.com, netdev@vger.kernel.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47214 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751018AbaKJTdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 14:33:51 -0500
In-Reply-To: <CAEP_g=9Z4_xOnPJDcxGgSPvw1Heu5FGrij_L5Xbi6FeFfAwLvQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Fri, 7 Nov 2014 19:54:51 -0800

> On Fri, Nov 7, 2014 at 5:51 PM, Jay Vosburgh <jay.vosburgh@canonical.com> wrote:
>> Jesse Gross <jesse@nicira.com> wrote:
>>
>>>When doing GRO processing for UDP tunnels, we never add
>>>SKB_GSO_UDP_TUNNEL to gso_type - only the type of the inner protocol
>>>is added (such as SKB_GSO_TCPV4). The result is that if the packet is
>>>later resegmented we will do GSO but not treat it as a tunnel. This
>>>results in UDP fragmentation and since that is not the original layout
>>>of the skb, a panic in skb_segment().
>>>
>>>Reported-by: Jay Vosburgh <jay.vosburgh@canonical.com>
>>>Signed-off-by: Jesse Gross <jesse@nicira.com>
>>>---
>>>This problem occurs back to 3.14 for VXLAN but the FOU portion needs to
>>>be removed for kernels other than the 'net' tree.
>>
>>         This patch does not resolve the problem when applied to a
>> 3.17-ish kernel; the panic message is below, and appears to be
>> unchanged.
> 
> Hmm, OK, thanks for testing. I think this patch is probably still good
> to apply as it may solve a problem after we get this one figured out.

But if you want that to happen, you'll have to adjust the commit
message because it doesn't fix the crash reported by Jay at all.
