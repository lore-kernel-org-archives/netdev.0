From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: ehea debug output discussion
Date: Mon, 14 Aug 2006 14:38:50 +0200
Message-ID: <44E06EDA.6040404@de.ibm.com>
References: <44D99F38.8010306@de.ibm.com> <20060811215225.GH479@krispykreme> <44DE03B0.1060607@de.ibm.com> <20060813144400.GJ479@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Klein <osstklei@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Christoph Raisch <raisch@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>, roland@topspin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:5746 "EHLO
	mtagate6.de.ibm.com") by vger.kernel.org with ESMTP
	id S1750848AbWHNNRu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 09:17:50 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.7/8.13.7) with ESMTP id k7EDHn8B126976
	for <netdev@vger.kernel.org>; Mon, 14 Aug 2006 13:17:49 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7EDLaKu151828
	for <netdev@vger.kernel.org>; Mon, 14 Aug 2006 15:21:36 +0200
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7EDHmMd005758
	for <netdev@vger.kernel.org>; Mon, 14 Aug 2006 15:17:48 +0200
To: Anton Blanchard <anton@samba.org>
In-Reply-To: <20060813144400.GJ479@krispykreme>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

Anton Blanchard wrote:
> What is going to be done about the debug infrastructure in the ehea
> driver? The entry and exit traces really need to go, and any other debug
> you think is important to users needs to go into debugfs or something
> similar.
> 
> I see a similar issue in the ehca driver that I am in the middle of
> reviewing.
> 
> Anton

This is a statement for the eHEA driver:

Most of the debug outputs are redundant and we'll remove them
(EDEB_EN / EDEB_EX). We can use the standard mechanism for ethernet devices
(netif_msg_x) in most functions of ehea_main.c as we have the device struct
as a parameter available. However, some debug output mechanism is needed
where the standard mechanism does not work (functions that have no relation
to the dev struct do not have a dev parameter, for example
ehea_hcall_9arg_9ret in ehea_phyp.h)

The outcome of some internal discussions was that it is not acceptable for
our enterprise users of this type of driver on this target system to need a
recompile / reload of the driver for error analysis, so we need a mechanism
that allows us to switch on / off debug output at runtime. Therefore, we'd
introduce a stripped down version of EDEB.

Regards,
Jan-Bernd
