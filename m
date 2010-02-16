From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: Re: [PATCH 13/23 v3] mlx4: Unicast Loopback support
Date: Tue, 16 Feb 2010 17:28:38 +0200
Message-ID: <4B7AB9A6.1090209@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Yevgeny Petrilin, Roland Dreier <rdreier@cisco.com>,
	netdev@vger.kernel.org, liranl@mellanox.co.il,
	tziporet@mellanox.co.il
To: or.gerlitz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:36828 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755447Ab0BPP2n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2010 10:28:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday -10,January,-28163 09:59 PM, Or Gerlitz [or.gerlitz@gmail.com] wrote:
> Yevgeny Petrilin <yevgenyp@mellanox.co.il> wrote:
>> Or Gerlitz [or.gerlitz@gmail.com] wrote:
> 
>>> I wasn't sure what is the use case here, isn't loopback handled by higher levels at the network stack?
> 
>> The use case is two VMs using the same physical adapter.
> 
> I am still not with you: are you referring to the case where each VM is being served by a different VF? in that case, the VF driver (mlx4_en) has no way to know its a "loopback" packet, and switching between VFs can be programmed to the PF by the PF driver (modified mlx4_core).
> 
> If you are talking to the case both VMs are being served by the same PCI function --> same NIC then again, loopback is handled in higher level.
> 
> Is there a 3rd use case?
> 
> Or.

There is no third case. I am referring to the case where two VMs are served by two different VFs.
The mlx4_en driver doesn't know whether a packet is loopback or not, it assumes that all packets can
be loopbacks and writes the dmac to the control segment.
The HW checks this field and decides whether the packet is loopback or not (by checking whether the written mac
matches one of the registered macs on this device).
