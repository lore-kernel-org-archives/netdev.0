From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v3 8/8] geneve: break dependency to network
 drivers
Date: Fri, 8 Jan 2016 21:47:07 +0100
Message-ID: <5690204B.7000004@stressinduktion.org>
References: <1452123571-19140-1-git-send-email-hannes@stressinduktion.org>
 <1452123571-19140-9-git-send-email-hannes@stressinduktion.org>
 <CAEh+42h79Sxc4JwzH_zMm+MZ-CmQWGdX1Qiz7epJmj2nCiAAVQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:59040 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755923AbcAHUrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 15:47:11 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 53565202D5
	for <netdev@vger.kernel.org>; Fri,  8 Jan 2016 15:47:10 -0500 (EST)
In-Reply-To: <CAEh+42h79Sxc4JwzH_zMm+MZ-CmQWGdX1Qiz7epJmj2nCiAAVQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07.01.2016 01:18, Jesse Gross wrote:
> I think we should merge vxlan_get_rx_port() and geneve_get_rx_port()
> into a single generic function. For drivers that support both, they
> now have two calls to get notified for all offloaded ports. This
> actually can cause problems related to duplicates, similar to what you
> feared before.

Checking out the ndo_add_vxlan_port callbacks, we cannot change how we 
refresh the ports unfortunately. For some drivers it might be easy to 
update, some look a little bit more complicated.

I guess we should try to keep more complexity in the core and make sure 
we only call those functions if necessary for the particular type of 
offload than to replicate the logic in each driver.

If you agree I prepare this series with the changes to have separate 
callbacks, address your other feedback and send it out.

Thanks,
Hannes
