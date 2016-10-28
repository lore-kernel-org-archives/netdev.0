From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 2/2] at803x: double check SGMII side autoneg
Date: Fri, 28 Oct 2016 17:24:10 -0500
Message-ID: <5813D00A.8080005@codeaurora.org>
References: <1477305654-11328-1-git-send-email-zefir.kurtisi@neratec.com>
 <1477305654-11328-3-git-send-email-zefir.kurtisi@neratec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Zefir Kurtisi <zefir.kurtisi@neratec.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:42248 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756697AbcJ1WYN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 18:24:13 -0400
In-Reply-To: <1477305654-11328-3-git-send-email-zefir.kurtisi@neratec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Zefir Kurtisi wrote:
> +	/* check if the SGMII link is OK. */
> +	if (!(phy_read(phydev, AT803X_PSSR) & AT803X_PSSR_MR_AN_COMPLETE)) {
> +		pr_warn("803x_aneg_done: SGMII link is not ok\n");
> +		aneg_done = 0;

I see this message appear sometimes when bring up the interface via 
ifup.  However, contrary to your patch description, everything seems to 
work:

$ iperf3 -c 192.168.1.1 -t 3600
Connecting to host 192.168.1.1, port 5201
[  4] local 192.168.1.2 port 52640 connected to 192.168.1.1 port 5201
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-1.00   sec   109 MBytes   909 Mbits/sec    0    485 KBytes
[  4]   1.00-2.00   sec   108 MBytes   902 Mbits/sec    0    622 KBytes

I wonder if you're impacted with all of the pause frame problems I'm having.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
