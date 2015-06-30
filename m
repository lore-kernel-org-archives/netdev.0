From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: mlx4: "failed to allocate default counter port 1"
Date: Tue, 30 Jun 2015 15:53:16 +0300
Message-ID: <5592913C.3000207@mellanox.com>
References: <alpine.LFD.2.11.1506301229520.1799@denkbrett>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eran Ben Elisha <eranbe@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	<netdev@vger.kernel.org>
To: Sebastian Ott <sebott@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0070.outbound.protection.outlook.com ([157.55.234.70]:64482
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752956AbbF3MxG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jun 2015 08:53:06 -0400
In-Reply-To: <alpine.LFD.2.11.1506301229520.1799@denkbrett>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/30/2015 1:45 PM, Sebastian Ott wrote:
> [   88.909558] mlx4_slave_cmd op=3840, ret=-22, status=3
> [   88.909562] mlx4_core 0000:00:00.0: mlx4_allocate_default_counters: failed to allocate default counter port 1 err -22
> [   88.909564] mlx4_core 0000:00:00.0: Failed to allocate default counters, aborting
> [   88.961735] mlx4_core: probe of 0000:00:00.0 failed with error -22

Do you run the VF on the same system/kernel as the PF, or the VF is 
probed to VM which runs the latest kernel and the PF runsolder kernel 
(which?)

Can you also hook the PF code that serves this flow to see where we 
actually fail? basically, we should be going this way 
mlx4_ALLOC_RES_wrapper --> counter_alloc_res -- so I'd like to see which 
of the branches in counter_alloc_res fails...

Or.
