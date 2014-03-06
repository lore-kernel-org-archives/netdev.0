From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [RFC] CPSW: dual standalone emac mode / bonding
Date: Thu, 6 Mar 2014 13:52:41 +0530
Message-ID: <53183051.7080801@ti.com>
References: <20140305183318.16f5dafa@frequentis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Christian Engelmayer <christian.engelmayer@frequentis.com>,
	<netdev@vger.kernel.org>, <linux-omap@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:58958 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751811AbaCFIWn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2014 03:22:43 -0500
In-Reply-To: <20140305183318.16f5dafa@frequentis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 05 March 2014 11:03 PM, Christian Engelmayer wrote:
> Has anybody successfuly setup ethernet bonding on a TI AM335x based system using
> the CPSW in dual standalone emac mode?
>
> I am running an active-backup test setup - momentarily still running Linux 3.2 -
> and experience repeated loss of ethernet connectivity. That happens eg. after
> the board is idle and receives an own ARP request on the backup slave interface.
> It seems that the corresponding reply does not reach the CPU and I can see via
> SysFs that the host's address entry got associated with the external backup port.
>
>    index 2, raw: 00000000 10000018 31e00669, type: addr(1), addr: 00:18:31:e0:06:69,
>       uctype: persistant(0), port: 0 --> uctype: persistant(0), port: 2
>
> As expected, triggering a unicast from the board or bypassing the ALE recovers

It seems that some other system in the network is using the same mac in
your EVM or there is a loop detected in your network which leads that
ALE is learning that there is  system with your MAC and updating the ALE
table that the mac is there and which leads your own packet will be
forwarded to that port and not to host port.

When ever you start a transmission the ALE learns the host port MAC is x
and updates ALE table with that port number and so there in your network
is working.

Regards
Mugunthan V N
