From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 2/2] at803x: double check SGMII side autoneg
Date: Wed, 18 Jan 2017 09:02:44 -0600
Message-ID: <7d61d23d-60f5-a77e-42ad-fccf6e8d5878@codeaurora.org>
References: <1477305654-11328-1-git-send-email-zefir.kurtisi@neratec.com>
 <1477305654-11328-3-git-send-email-zefir.kurtisi@neratec.com>
 <e063a5fd-a1c5-e9ec-1700-21c6974a7cbe@codeaurora.org>
 <3291b7c1-7bf6-d776-adab-b89c9cd9be38@neratec.com>
 <5763c2fb-7286-15b0-091f-1abf26c0afe7@codeaurora.org>
 <b12e913d-874b-734a-4401-88315b8459dc@neratec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com
To: Zefir Kurtisi <zefir.kurtisi@neratec.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:54822 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751727AbdARPCr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 10:02:47 -0500
In-Reply-To: <b12e913d-874b-734a-4401-88315b8459dc@neratec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/18/2017 07:53 AM, Zefir Kurtisi wrote:
> No, not necessarily. The SGMII link default configuration is set such that you do
> not have to bother at all.

Does the SGMII link need to make the speed and duplex of the external link?

https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c#n50

Here is where I can configure the SGMII link to match whatever phydev says 
the external link is.  This is code that was handed down to me.  I've never 
really understood what the purpose was.  Shouldn't I just be able to 
configure the SGMII link to 1Gbs full-duplex, regardless of what the external 
link is set to?

> That is, if in your case you see the warning popping up but the link always
> regains connection, then it is an ignorable false positive.

Unfortunately, I can't really ignore it because genphy does this:

$ ifup eth1
[ 1034.754276] qcom-emac QCOM8070:00 eth1: Link is Up - 1Gbps/Full - flow 
control rx/tx

But the at803x driver does this:

$ ifup eth1
[ 1020.507728] 803x_aneg_done: SGMII link is not ok
[ 1020.513517] qcom-emac QCOM8070:00 eth1: Link is Up - 1Gbps/Full - flow 
control rx/tx
[ 1020.522839] qcom-emac QCOM8070:00 eth1: Link is Up - 1Gbps/Full - flow 
control rx/tx

Customers are going to complain.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
