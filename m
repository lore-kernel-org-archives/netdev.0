From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] net: phy: at803x: the Atheros 8031 supports pause frames
Date: Mon, 31 Oct 2016 16:14:26 -0500
Message-ID: <5817B432.7070304@codeaurora.org>
References: <1477605901-30906-1-git-send-email-timur@codeaurora.org>
 <f34cd143-bf04-c17f-b3d6-e3077715a72a@gmail.com>
 <58127E8E.4020301@codeaurora.org>
 <9b817af9-a519-9010-e57b-8de8972088b8@gmail.com>
 <5813AFC1.50506@codeaurora.org>
 <144cc092-f04d-f5eb-503c-51e87c214b66@gmail.com>
 <58177E17.6070704@codeaurora.org>
 <39bda1bc-255b-64d0-3e7a-d3a6f00786c3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        zefir.kurtisi@neratec.com, scampbel@codeaurora.org,
        alokc@codeaurora.org, shankerd@codeaurora.org, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:38246 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S946965AbcJaVO3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 17:14:29 -0400
In-Reply-To: <39bda1bc-255b-64d0-3e7a-d3a6f00786c3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli wrote:
>>pause    asym_pause    enable tx?    enable rx?
>>-----    ----------    ----------    ----------
>>   0           0           No             No
>>   0           1           Yes            No
>>   1           0           Yes            Yes
>>   1           1           No             Yes
>>
>>The last two seem backwards.  The internal driver enables RX and TX if
>>pause and asym_pause is enabled.

Is this chart correct?  I see drivers handle this differently.

nb8800_pause_config() has this:

	priv->pause_rx = phydev->pause;
	priv->pause_tx = phydev->pause ^ phydev->asym_pause;

But bcm_sf2_sw_adjust_link() does this:

	if (phydev->pause) {
		if (phydev->asym_pause)
			reg |= TX_PAUSE_EN;
		reg |= RX_PAUSE_EN;
	}

Which one is correct?

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
