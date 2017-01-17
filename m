From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 2/2] at803x: double check SGMII side autoneg
Date: Tue, 17 Jan 2017 17:32:10 -0600
Message-ID: <e063a5fd-a1c5-e9ec-1700-21c6974a7cbe@codeaurora.org>
References: <1477305654-11328-1-git-send-email-zefir.kurtisi@neratec.com>
 <1477305654-11328-3-git-send-email-zefir.kurtisi@neratec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com
To: Zefir Kurtisi <zefir.kurtisi@neratec.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:39640 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751522AbdAQXcM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 18:32:12 -0500
In-Reply-To: <1477305654-11328-3-git-send-email-zefir.kurtisi@neratec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/24/2016 05:40 AM, Zefir Kurtisi wrote:
> As a result, if you ever see a warning
> '803x_aneg_done: SGMII link is not ok' you will
> end up having an Ethernet link up but won't get
> any data through. This should not happen, if it
> does, please contact the module maintainer.

I am now seeing this:

ubuntu@ubuntu:~$ ifup eth1
ubuntu@ubuntu:~$ [  588.687689] 803x_aneg_done: SGMII link is not ok
[  588.694909] qcom-emac QCOM8070:00 eth1: Link is Up - 1Gbps/Full - flow 
control rx/tx
[  588.703985] qcom-emac QCOM8070:00 eth1: Link is Up - 1Gbps/Full - flow 
control rx/tx

ubuntu@ubuntu:~$ ping 192.168.3.1
PING 192.168.3.1 (192.168.3.1) 56(84) bytes of data.
64 bytes from 192.168.3.1: icmp_seq=1 ttl=64 time=0.502 ms
64 bytes from 192.168.3.1: icmp_seq=2 ttl=64 time=0.244 ms
64 bytes from 192.168.3.1: icmp_seq=3 ttl=64 time=0.220 ms
^C
--- 192.168.3.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2107ms
rtt min/avg/max/mdev = 0.220/0.322/0.502/0.127 ms

So I do get the "SGMII link is not ok" message, but my connection is fine.  I 
don't know why the link-up message is displayed twice.  It's only displayed 
once if I use the genphy driver instead of the at803x driver.

I'm going to debug the at803x to see what it does that causes the double 
link-up message.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
