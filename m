From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: dhcp nfsroot booting failure on bb white
Date: Wed, 12 Aug 2015 14:22:53 +0530
Message-ID: <55CB0965.9020300@ti.com>
References: <20150812083629.GA778@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Alexander Aring <alex.aring@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:43324 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753755AbbHLIxD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2015 04:53:03 -0400
In-Reply-To: <20150812083629.GA778@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 12 August 2015 02:06 PM, Alexander Aring wrote:
> Hi,
> 
> my beaglebone (white edition) fails to boot via dhcp and nfsroot. The
> last messages which I see are:
> 
> ...
> [    2.970593] Sending DHCP requests .
> [    5.996876] cpsw 4a100000.ethernet eth0: Link is Up - 100Mbps/Full -
> flow control off
> 
> 
> then it stucks forever. I reverted the recently cpsw patches:
> 
> 32a7432c0fb8b0117961bdc7ab256667d039de16 ("drivers: net: cpsw: add
> separate napi for tx")
> 
> d354eb85d61803e07831b68d1985cd9cfe2f8b59 ("drivers: net: cpsw:
> dual_emac: simplify napi usage")
> 
> 870915feabdc3af5f0ebb72d1fcf96bff01837b0 ("drivers: net: cpsw: remove
> disable_irq/enable_irq as irq can be masked from cpsw itself")
> 
> 
> I did a test after each revert, I finally figured out that after reverting
> the last patch:
> 
> 870915feabdc3af5f0ebb72d1fcf96bff01837b0 ("drivers: net: cpsw: remove
> disable_irq/enable_irq as irq can be masked from cpsw itself")
> 
> it worked again to boot via dhcp nfsroot.
> 
> 
> My bootparameters are:
> 
> commandline: console=ttyO0,115200n8 console=ttyO0,115200n8 ip=dhcp
> root=/dev/nfs nfsroot=$IP:$NFS_EXPORT,v3,tcp
> 

I am already looking into it. Will submit a fix soon. The issue is with
AM335x PG1.0 as there is a errata in CPSW interrupts, PG2.x and other
SoCs are working fine.

Regards
Mugunthan V N
