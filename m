From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: Re: Re: [PATCH 18/23 v3] mlx4_core: Managing common port filters
 by
Date: Wed, 10 Feb 2010 19:22:51 +0200
Message-ID: <4B72EB6B.9000708@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: yevgenyp@mellanox.co.il, Roland Dreier <rdreier@cisco.com>,
	netdev@vger.kernel.org, tziporet@mellanox.co.il,
	liranl@mellanox.co.il
To: or.gerlitz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:40450 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754635Ab0BJRW4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2010 12:22:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday -10,January,-28163 09:59 PM, Or Gerlitz [or.gerlitz@gmail.com] wrote:
> Yevgeny Petrilin <yevgenyp@mellanox.co.il> wrote:
>> The Multicast filter configuration is done by the master, that manages 
>> the filter which is common for all the functions.
>> The VLAN filter is a bitwise OR of all the VLAN filters for all 
>> functions, the result is a false-positive filter.
> 
> Reading through patches "18/23 v3 mlx4_core: Managing common port filters..." &&
> "16/23 v3 mlx4_core: Multi-Function MCG support" I have difficulties to follow on the vlan and multicast filtering related changes and proposed architecture.
> 
> Can you explain them in a bit more detailed fashion? For example, in the multicast case I believe that currently a bloom filter is applied  at the port level and each packet which pass the filter and has no registered QP is consumed by the EN driver.
> At some point
> my understanding was that everyone (all PFs, all VFs, etc) move to exact match, is it correct?
> 
> As for the false-positive vlan filter, I understand that this means further filtering has to be applied by some driver. Where you thinking on the 802q driver? what about the case where a VF driver is assigned a vlan, does the mlx4 VF code does such filtering?
> 
> 
> Or.
The multicast bloom filter is a false-positive filter per port.
All multicast packets go through the Multicast tables mechanism where every PF/VF is registered for every multicast address it listens to.
We will add support for per-Function multicast promiscuous mode.

The deal with the VLAN filter is similar, it includes all VIDs that some PF/VF requested.
We plan to add a MAC+VLAN filter implementation, that would cancel the need in this filter.

Yevgeny

