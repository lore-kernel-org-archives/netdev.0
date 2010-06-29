From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] s2io: read rx_packets count from the hardware stats
Date: Mon, 28 Jun 2010 23:52:23 -0700 (PDT)
Message-ID: <20100628.235223.191401839.davem@davemloft.net>
References: <20100624233230.5864.67401.stgit@leela.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ramkrishna.Vepa@exar.com,
	sivakumar.subramani@exar.com, sreenivasa.honnur@exar.com
To: mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59196
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751967Ab0F2GwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 02:52:10 -0400
In-Reply-To: <20100624233230.5864.67401.stgit@leela.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Schmidt <mschmidt@redhat.com>
Date: Fri, 25 Jun 2010 01:32:32 +0200

> Most of the statistics the s2io driver provides in /proc/net/dev
> it reads directly from the hardware counters. For some reason it does
> not do that for rx_packets. It counts rx_packets purely in software.
> 
> A customer reported a bug where in /proc/net/dev the 'multicast' counter
> was increasing faster than 'packets' ( = rx_packets in the source code).
> This confuses userspace, especially snmpd.
> 
> The hardware provides a counter for the total number of received
> frames (RMAC_VLD_FRMS) which the driver can use for the rx_packets
> statistic. By reading both statistics from the hardware it makes sure
> that all multicast frames are included in the total.
> 
> The customer tested a patch like this (only modified for RHEL5) with
> S2io Inc. Xframe II 10Gbps Ethernet (rev 02)
> and it fixed the problem.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

Please also use the rmac_data_octets HW statistic for rx_bytes
otherwise rx_bytes will be out of sync with the other stats too.
