From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Subject: Re: [PATCH 2/2] at803x: double check SGMII side autoneg
Date: Tue, 1 Nov 2016 12:13:00 +0100
Message-ID: <8a1372f4-4355-f27b-75a5-5aefedeb3ac1@neratec.com>
References: <1477305654-11328-1-git-send-email-zefir.kurtisi@neratec.com>
 <1477305654-11328-3-git-send-email-zefir.kurtisi@neratec.com>
 <5813D00A.8080005@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Timur Tabi <timur@codeaurora.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.neratec.com ([46.140.151.2]:27395 "EHLO mail.neratec.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1168518AbcKALND (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Nov 2016 07:13:03 -0400
In-Reply-To: <5813D00A.8080005@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/29/2016 12:24 AM, Timur Tabi wrote:
> Zefir Kurtisi wrote:
>> +    /* check if the SGMII link is OK. */
>> +    if (!(phy_read(phydev, AT803X_PSSR) & AT803X_PSSR_MR_AN_COMPLETE)) {
>> +        pr_warn("803x_aneg_done: SGMII link is not ok\n");
>> +        aneg_done = 0;
> 
> I see this message appear sometimes when bring up the interface via ifup. 
> However, contrary to your patch description, everything seems to work:
> 
Right so, seeing the message and still having the SGMII link up and working is
what happens most. But randomly (in our setup it is in the order of 1%) we see
that SGMII remains down after a suspend-resume cycle. This message is a required
but not sufficient condition.

> $ iperf3 -c 192.168.1.1 -t 3600
> Connecting to host 192.168.1.1, port 5201
> [  4] local 192.168.1.2 port 52640 connected to 192.168.1.1 port 5201
> [ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
> [  4]   0.00-1.00   sec   109 MBytes   909 Mbits/sec    0    485 KBytes
> [  4]   1.00-2.00   sec   108 MBytes   902 Mbits/sec    0    622 KBytes
> 
> I wonder if you're impacted with all of the pause frame problems I'm having.
> 

I doubt, since resetting SGMII link alone (via toggling MII_BMCR on fibre page)
brings back the SGMII communication, I assume it to be below the MAC layer.

Are you aware of any related erratas for the at803x? I am not and therefore left
alone with my guesswork.
